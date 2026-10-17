import 'package:dio/dio.dart';

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

/// A Dio interceptor that injects Bearer authorization headers and provides
/// a structured extension point for token refresh workflows.
class AuthInterceptor extends Interceptor {
  final AuthTokenProvider? tokenProvider;

  AuthInterceptor({this.tokenProvider});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // If an Authorization header is already provided manually, do not overwrite it.
    if (options.headers.containsKey('Authorization')) {
      return handler.next(options);
    }

    if (tokenProvider != null) {
      try {
        final token = await tokenProvider!.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // Continue request without token if secure retrieval fails.
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Extension point for 401 Unauthorized handling & automatic token refresh.
    // If tokenProvider is attached and the error is a 401 on an authenticated endpoint,
    // future token refresh logic will be triggered here.
    return handler.next(err);
  }
}
