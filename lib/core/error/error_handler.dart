import 'dart:io';

import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Central utility to map network, serialization, and runtime errors into domain [Failure]s.
class ErrorHandler {
  const ErrorHandler._();

  /// Converts any thrown [error] into a strongly typed [Failure].
  static Failure handle(Object error) {
    if (error is Failure) {
      return error;
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is SocketException) {
      return const NetworkFailure();
    }

    if (error is FormatException) {
      return const SerializationFailure();
    }

    if (error is AppException) {
      return _handleAppException(error);
    }

    return UnknownFailure(message: error.toString());
  }

  static Failure _handleDioException(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Security certificate verification failed.',
        );

      case DioExceptionType.badResponse:
        final response = dioError.response;
        final statusCode = response?.statusCode;
        final message = _extractMessage(response?.data);

        if (statusCode == 401) {
          return UnauthorizedFailure(
            message:
                message ??
                'Session expired or invalid credentials. Please sign in again.',
            statusCode: 401,
          );
        }

        if (statusCode == 403) {
          return UnauthorizedFailure(
            message: message ?? 'Access denied. Please re-authenticate.',
            statusCode: 403,
          );
        }

        if (statusCode == 404) {
          return NotFoundFailure(
            message: message ?? 'Requested resource was not found.',
            statusCode: 404,
          );
        }

        if (statusCode != null && statusCode >= 500) {
          return ServerFailure(
            message: 'Server error ($statusCode). Please try again shortly.',
            statusCode: statusCode,
          );
        }

        return ServerFailure(
          message:
              message ?? 'An error occurred while processing your request.',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'Request was cancelled.');

      case DioExceptionType.unknown:
        if (dioError.error is SocketException) {
          return const NetworkFailure();
        }
        if (dioError.error is FormatException) {
          return const SerializationFailure();
        }
        return UnknownFailure(
          message: dioError.message ?? 'An unexpected network error occurred.',
        );
    }
  }

  static Failure _handleAppException(AppException exception) {
    return switch (exception) {
      ServerException e => ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      NetworkException e => NetworkFailure(message: e.message),
      TimeoutException e => TimeoutFailure(message: e.message),
      UnauthorizedException e => UnauthorizedFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      NotFoundException e => NotFoundFailure(
        message: e.message,
        statusCode: e.statusCode,
      ),
      CacheException e => CacheFailure(message: e.message),
      SerializationException e => SerializationFailure(message: e.message),
    };
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        return data['message'] as String;
      }
      if (data['error'] is String && (data['error'] as String).isNotEmpty) {
        return data['error'] as String;
      }
    } else if (data is String && data.trim().isNotEmpty) {
      // Sometimes APIs or reverse proxies return plain strings
      if (!data.startsWith('<')) {
        return data.trim();
      }
    }
    return null;
  }
}
