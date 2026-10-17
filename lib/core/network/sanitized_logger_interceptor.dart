import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A secure, debug-only Dio interceptor that logs HTTP network traffic while strictly
/// sanitizing sensitive authentication data such as passwords, access tokens, and refresh tokens.
class SanitizedLoggerInterceptor extends Interceptor {
  final bool isEnabled;

  const SanitizedLoggerInterceptor({this.isEnabled = kDebugMode});

  static const Set<String> _sensitiveKeyPatterns = {
    'password',
    'token',
    'accesstoken',
    'refreshtoken',
    'secret',
    'client_secret',
    'authorization',
    'cookie',
    'key',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (isEnabled) {
      final sanitizedHeaders = _sanitizeMap(options.headers);
      final sanitizedData = _sanitizePayload(options.data);

      developer.log(
        '--> ${options.method.toUpperCase()} ${options.uri}\n'
        'Headers: $sanitizedHeaders\n'
        'Body: $sanitizedData',
        name: 'ShopSphere.Network',
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (isEnabled) {
      final sanitizedData = _sanitizePayload(response.data);

      developer.log(
        '<-- ${response.statusCode} ${response.requestOptions.uri}\n'
        'Body: $sanitizedData',
        name: 'ShopSphere.Network',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isEnabled) {
      final sanitizedData = _sanitizePayload(err.response?.data);

      developer.log(
        '<-- ERROR [${err.response?.statusCode ?? 'NO_STATUS'}] ${err.requestOptions.uri}\n'
        'Type: ${err.type}\n'
        'Message: ${err.message}\n'
        'Body: $sanitizedData',
        name: 'ShopSphere.Network',
        error: err,
      );
    }
    super.onError(err, handler);
  }

  /// Sanitizes any map recursively (headers, request body, query params).
  Map<String, dynamic> _sanitizeMap(Map<dynamic, dynamic> map) {
    final sanitized = <String, dynamic>{};
    for (final entry in map.entries) {
      final key = entry.key.toString();
      final lowerKey = key.toLowerCase();

      if (_isSensitiveKey(lowerKey)) {
        if (lowerKey == 'authorization' && entry.value is String) {
          final authStr = entry.value as String;
          if (authStr.startsWith('Bearer ')) {
            sanitized[key] = 'Bearer [REDACTED]';
          } else {
            sanitized[key] = '[REDACTED]';
          }
        } else {
          sanitized[key] = '[REDACTED]';
        }
      } else {
        sanitized[key] = _sanitizePayload(entry.value);
      }
    }
    return sanitized;
  }

  /// Recursively walks JSON payloads (maps, lists, primitives) to sanitize sensitive keys.
  dynamic _sanitizePayload(dynamic payload) {
    if (payload == null) return null;
    if (payload is Map) {
      return _sanitizeMap(payload);
    }
    if (payload is List) {
      return payload.map(_sanitizePayload).toList();
    }
    return payload;
  }

  bool _isSensitiveKey(String lowerKey) {
    return _sensitiveKeyPatterns.any((pattern) => lowerKey.contains(pattern));
  }

  /// Public sanitization helper exposed for testing.
  dynamic sanitizeForTesting(dynamic payload) => _sanitizePayload(payload);
}
