/// Pure Dart domain failure abstraction.
///
/// Returned by repositories and use cases to represent operational failures
/// without throwing uncaught exceptions up into presentation widgets.
sealed class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);

  @override
  String toString() =>
      '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Represents a failure returned by the remote API / backend.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Represents network connectivity failures (offline, no internet, unreachable host).
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message =
        'No internet connection. Please check your network and retry.',
  });
}

/// Represents timeout failures when communicating with external services.
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'The server took too long to respond. Please try again.',
  });
}

/// Represents authentication or authorization failures (e.g. 401 Unauthorized, 403 Forbidden).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Your session has expired. Please sign in again.',
    super.statusCode = 401,
  });
}

/// Represents resource not found failures (HTTP 404).
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested item was not found.',
    super.statusCode = 404,
  });
}

/// Represents failures related to local storage or caching.
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Represents JSON deserialization or schema mismatch errors.
class SerializationFailure extends Failure {
  const SerializationFailure({
    super.message = 'Failed to parse response from server.',
  });
}

/// Represents client-side input validation or domain constraint violations.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Catch-all failure for unexpected runtime exceptions.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}
