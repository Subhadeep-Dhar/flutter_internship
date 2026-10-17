/// Base class for all application exceptions.
///
/// Thrown by the data layer when low-level or network operations fail.
/// Handled by repositories and mapped into [Failure] objects.
sealed class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() =>
      '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Thrown when the remote server returns a 5xx error or non-specific 4xx error.
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

/// Thrown when device connectivity fails (e.g. no internet, DNS resolution fails).
class NetworkException extends AppException {
  const NetworkException({
    super.message =
        'Unable to connect to the server. Please check your internet connection.',
  });
}

/// Thrown when an HTTP request or socket times out.
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'The connection timed out. Please try again.',
  });
}

/// Thrown when credentials or access tokens are invalid or expired (HTTP 401).
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message =
        'Session expired or invalid credentials. Please sign in again.',
    super.statusCode = 401,
  });
}

/// Thrown when a requested resource is not found (HTTP 404).
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
  });
}

/// Thrown when local cache or persistence read/write fails.
class CacheException extends AppException {
  const CacheException({required super.message});
}

/// Thrown when response parsing or JSON serialization fails.
class SerializationException extends AppException {
  const SerializationException({
    super.message = 'Failed to process server response.',
  });
}
