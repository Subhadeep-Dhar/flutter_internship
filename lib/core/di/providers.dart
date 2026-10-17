import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Provider for [AuthInterceptor].
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});

/// Provider for debug-only, sanitized network logging interceptor.
final sanitizedLoggerInterceptorProvider = Provider<SanitizedLoggerInterceptor>(
  (ref) {
    return const SanitizedLoggerInterceptor();
  },
);

/// Central provider for the shared [Dio] client configured for the DummyJSON API.
final dioProvider = Provider<Dio>((ref) {
  final authInterceptor = ref.watch(authInterceptorProvider);
  final loggerInterceptor = ref.watch(sanitizedLoggerInterceptorProvider);

  return DioClient.create(
    authInterceptor: authInterceptor,
    loggerInterceptor: loggerInterceptor,
  );
});
