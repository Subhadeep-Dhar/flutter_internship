import 'dart:async';

import 'package:dio/dio.dart';

import 'api_endpoints.dart';

/// Contract for accessing and refreshing authentication tokens.
///
/// Implemented by the authentication data layer and injected into [AuthInterceptor].
abstract class AuthTokenProvider {
  /// Returns the current access token, or null if unauthenticated.
  Future<String?> getAccessToken();

  /// Returns the current refresh token, or null if unauthenticated.
  Future<String?> getRefreshToken();

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns true if refresh succeeded, false otherwise.
  Future<bool> refreshToken();

  /// Clears stored tokens and signs out the user upon terminal token expiry.
  Future<void> onAuthenticationExpired();
}

/// A robust Dio interceptor that injects Bearer authorization headers into protected
/// requests, handles single-flight automatic token refresh on HTTP 401, retries
/// failed requests at most once, and avoids retry loops on public auth endpoints.
class AuthInterceptor extends Interceptor {
  final AuthTokenProvider? tokenProvider;
  Dio? dio;

  AuthInterceptor({this.tokenProvider, this.dio});

  /// Attaches the parent [Dio] instance needed to execute retried requests.
  void attachDio(Dio dioInstance) {
    dio = dioInstance;
  }

  /// Single-flight lock future to ensure concurrent 401 responses share a single refresh call.
  Future<bool>? _refreshFuture;

  static const String _retryHeaderKey = 'x-shopsphere-retry';

  bool _isPublicAuthEndpoint(String path) {
    return path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.refresh);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Never attach Bearer token to login or refresh endpoints
    if (_isPublicAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    // 2. If an Authorization header is already set manually, preserve it
    if (options.headers.containsKey('Authorization')) {
      return handler.next(options);
    }

    // 3. Attach stored Bearer access token if available
    if (tokenProvider != null) {
      try {
        final token = await tokenProvider!.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // Proceed without token if secure retrieval fails
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final statusCode = response?.statusCode;
    final requestOptions = err.requestOptions;

    // 1. Only intercept 401 Unauthorized errors on protected endpoints
    if (statusCode != 401 ||
        _isPublicAuthEndpoint(requestOptions.path) ||
        tokenProvider == null) {
      return handler.next(err);
    }

    // 2. Prevent infinite retry loops: check if this request has already been retried
    final isRetry = requestOptions.extra[_retryHeaderKey] == true;
    if (isRetry) {
      return handler.next(err);
    }

    // 3. Check if a refresh token exists
    final refreshToken = await tokenProvider!.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await tokenProvider!.onAuthenticationExpired();
      return handler.next(err);
    }

    // 4. Concurrency-safe single-flight refresh
    try {
      final refreshSuccess = await _performSingleFlightRefresh();

      if (!refreshSuccess) {
        await tokenProvider!.onAuthenticationExpired();
        return handler.next(err);
      }

      // 5. Token refresh succeeded: fetch the new access token
      final newAccessToken = await tokenProvider!.getAccessToken();
      if (newAccessToken == null || newAccessToken.isEmpty || dio == null) {
        await tokenProvider!.onAuthenticationExpired();
        return handler.next(err);
      }

      // 6. Build the retried request with updated credentials and retry flag
      final retryOptions = requestOptions.copyWith();
      retryOptions.extra[_retryHeaderKey] = true;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final retriedResponse = await dio!.fetch(retryOptions);
      return handler.resolve(retriedResponse);
    } catch (refreshErr) {
      await tokenProvider!.onAuthenticationExpired();
      return handler.next(err);
    }
  }

  Future<bool> _performSingleFlightRefresh() {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    _refreshFuture = tokenProvider!.refreshToken().whenComplete(() {
      _refreshFuture = null;
    });

    return _refreshFuture!;
  }
}
