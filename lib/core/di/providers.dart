import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/restore_session_usecase.dart';
import '../../features/auth/presentation/controllers/auth_notifier.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_categories_usecase.dart';
import '../../features/products/domain/usecases/get_product_by_id_usecase.dart';
import '../../features/products/domain/usecases/get_products_by_category_usecase.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/search_products_usecase.dart';
import '../../features/products/presentation/controllers/product_detail_notifier.dart';
import '../../features/products/presentation/controllers/product_detail_state.dart';
import '../../features/products/presentation/controllers/product_list_notifier.dart';
import '../../features/products/presentation/controllers/product_list_state.dart';
import '../network/api_endpoints.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../network/sanitized_logger_interceptor.dart';

/// Provider for [SharedPreferences].
///
/// Overridden in `main.dart` with an initialized instance before `runApp`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

/// Provider for [FlutterSecureStorage].
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider for debug-only, sanitized network logging interceptor.
final sanitizedLoggerInterceptorProvider = Provider<SanitizedLoggerInterceptor>(
  (ref) {
    return const SanitizedLoggerInterceptor();
  },
);

/// Independent Dio instance for authentication services (login, refresh)
/// preventing cyclic dependency loops with [AuthInterceptor].
final authDioProvider = Provider<Dio>((ref) {
  final logger = ref.watch(sanitizedLoggerInterceptorProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      sendTimeout: ApiEndpoints.sendTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.add(logger);
  return dio;
});

/// Provider for [AuthLocalDataSource].
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthLocalDataSourceImpl(storage);
});

/// Provider for [AuthRemoteDataSource].
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(authDioProvider);
  return AuthRemoteDataSourceImpl(dio);
});

/// Provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final local = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

/// Provider for [LoginUseCase].
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

/// Provider for [RestoreSessionUseCase].
final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(ref.watch(authRepositoryProvider));
});

/// Provider for [GetCurrentUserUseCase].
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

/// Provider for [LogoutUseCase].
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

/// Implementation of [AuthTokenProvider] that connects the network layer
/// to the authentication data sources.
class AppAuthTokenProvider implements AuthTokenProvider {
  final AuthLocalDataSource local;
  final AuthRemoteDataSource remote;
  final void Function(String message)? onExpired;

  AppAuthTokenProvider({
    required this.local,
    required this.remote,
    this.onExpired,
  });

  @override
  Future<String?> getAccessToken() => local.getAccessToken();

  @override
  Future<String?> getRefreshToken() => local.getRefreshToken();

  @override
  Future<bool> refreshToken() async {
    try {
      final token = await local.getRefreshToken();
      if (token == null || token.isEmpty) return false;
      final newTokens = await remote.refresh(token);
      await local.saveTokens(
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> onAuthenticationExpired() async {
    await local.clearTokens();
    onExpired?.call('Your session has expired. Please sign in again.');
  }
}

/// Provider delivering the configured [AuthTokenProvider].
final authTokenProvider = Provider<AuthTokenProvider>((ref) {
  final local = ref.watch(authLocalDataSourceProvider);
  final remote = ref.watch(authRemoteDataSourceProvider);
  return AppAuthTokenProvider(
    local: local,
    remote: remote,
    onExpired: (message) {
      ref.read(authNotifierProvider.notifier).onSessionExpired(message);
    },
  );
});

/// Provider for [AuthInterceptor] with single-flight refresh capability.
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final tokenProvider = ref.watch(authTokenProvider);
  return AuthInterceptor(tokenProvider: tokenProvider);
});

/// Central provider for the shared [Dio] client configured for authenticated API endpoints.
final dioProvider = Provider<Dio>((ref) {
  final authInterceptor = ref.watch(authInterceptorProvider);
  final loggerInterceptor = ref.watch(sanitizedLoggerInterceptorProvider);

  return DioClient.create(
    authInterceptor: authInterceptor,
    loggerInterceptor: loggerInterceptor,
  );
});

/// Central [NotifierProvider] managing authentication state.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Provider for [ProductRemoteDataSource].
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return ProductRemoteDataSourceImpl(dio);
});

/// Provider for [ProductRepository].
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remote = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource: remote);
});

/// Provider for [GetProductsUseCase].
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

/// Provider for [GetCategoriesUseCase].
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(productRepositoryProvider));
});

/// Provider for [SearchProductsUseCase].
final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  return SearchProductsUseCase(ref.watch(productRepositoryProvider));
});

/// Provider for [GetProductsByCategoryUseCase].
final getProductsByCategoryUseCaseProvider =
    Provider<GetProductsByCategoryUseCase>((ref) {
      return GetProductsByCategoryUseCase(ref.watch(productRepositoryProvider));
    });

/// Provider for [GetProductByIdUseCase].
final getProductByIdUseCaseProvider = Provider<GetProductByIdUseCase>((ref) {
  return GetProductByIdUseCase(ref.watch(productRepositoryProvider));
});

/// Central [NotifierProvider] managing catalogue product list state.
final productListNotifierProvider =
    NotifierProvider<ProductListNotifier, ProductListState>(
      ProductListNotifier.new,
    );

/// Family [NotifierProvider] managing individual product details state.
final productDetailNotifierProvider = NotifierProvider.autoDispose
    .family<ProductDetailNotifier, ProductDetailState, int>(
      ProductDetailNotifier.new,
    );
