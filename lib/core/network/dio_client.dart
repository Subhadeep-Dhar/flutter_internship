import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'auth_interceptor.dart';
import 'sanitized_logger_interceptor.dart';

/// Factory and configuration utility for the shared [Dio] HTTP client.
class DioClient {
  const DioClient._();

  /// Creates and configures a new [Dio] instance configured for the DummyJSON API.
  static Dio create({
    AuthInterceptor? authInterceptor,
    Interceptor? loggerInterceptor,
    BaseOptions? customOptions,
  }) {
    final defaultOptions = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      sendTimeout: ApiEndpoints.sendTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    );

    final dio = Dio(customOptions ?? defaultOptions);

    dio.interceptors.addAll([
      authInterceptor ?? AuthInterceptor(),
      loggerInterceptor ?? const SanitizedLoggerInterceptor(),
    ]);

    return dio;
  }
}
