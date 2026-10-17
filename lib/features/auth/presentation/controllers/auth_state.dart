import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';

/// Strongly-typed sealed state representing the authentication lifecycle.
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading({String? message}) = AuthLoading;
  const factory AuthState.authenticated({required User user}) =
      AuthAuthenticated;
  const factory AuthState.unauthenticated({String? message}) =
      AuthUnauthenticated;
  const factory AuthState.sessionExpired({required String message}) =
      AuthSessionExpired;
  const factory AuthState.sessionCheckFailed({required Failure failure}) =
      AuthSessionCheckFailed;

  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isLoading => this is AuthLoading;
  User? get userOrNull => switch (this) {
    AuthAuthenticated(user: final u) => u,
    _ => null,
  };
}

/// Initial state before any session validation has executed.
class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthInitial;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthState.initial()';
}

/// State while an asynchronous auth operation (login, session restore) is running.
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthLoading &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => 'AuthState.loading(message: $message)';
}

/// State when the user is successfully authenticated and verified by the backend.
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthenticated &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => Object.hash(runtimeType, user);

  @override
  String toString() => 'AuthState.authenticated(user: ${user.username})';
}

/// State when no user session is active (logged out or fresh launch without credentials).
class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUnauthenticated &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => 'AuthState.unauthenticated(message: $message)';
}

/// State when the user's refresh token expired or failed verification (HTTP 401 / 403).
class AuthSessionExpired extends AuthState {
  final String message;

  const AuthSessionExpired({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSessionExpired &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => 'AuthState.sessionExpired(message: $message)';
}

/// State when session restoration fails due to a recoverable network/server failure.
class AuthSessionCheckFailed extends AuthState {
  final Failure failure;

  const AuthSessionCheckFailed({required this.failure});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSessionCheckFailed &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'AuthState.sessionCheckFailed(failure: $failure)';
}
