import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import 'auth_state.dart';

/// Riverpod 3 controller managing the authentication lifecycle and state.
class AuthNotifier extends Notifier<AuthState> {
  final LoginUseCase? _injectedLoginUseCase;
  final RestoreSessionUseCase? _injectedRestoreSessionUseCase;
  final LogoutUseCase? _injectedLogoutUseCase;

  AuthNotifier({
    LoginUseCase? loginUseCase,
    RestoreSessionUseCase? restoreSessionUseCase,
    LogoutUseCase? logoutUseCase,
  }) : _injectedLoginUseCase = loginUseCase,
       _injectedRestoreSessionUseCase = restoreSessionUseCase,
       _injectedLogoutUseCase = logoutUseCase;

  late final LoginUseCase _loginUseCase;
  late final RestoreSessionUseCase _restoreSessionUseCase;
  late final LogoutUseCase _logoutUseCase;

  @override
  AuthState build() {
    _loginUseCase = _injectedLoginUseCase ?? ref.watch(loginUseCaseProvider);
    _restoreSessionUseCase =
        _injectedRestoreSessionUseCase ??
        ref.watch(restoreSessionUseCaseProvider);
    _logoutUseCase = _injectedLogoutUseCase ?? ref.watch(logoutUseCaseProvider);

    return const AuthState.initial();
  }

  /// Verifies whether valid tokens exist and validates the session against the server.
  Future<void> checkSession() async {
    if (state is AuthLoading) return;

    state = const AuthState.loading(message: 'Verifying session...');
    final result = await _restoreSessionUseCase();

    result.when(
      success: (user) {
        state = AuthState.authenticated(user: user);
      },
      error: (failure) {
        if (failure is UnauthorizedFailure) {
          state = const AuthState.unauthenticated();
        } else {
          // Expose a recoverable failure state for network outages or 5xx server issues
          state = AuthState.sessionCheckFailed(failure: failure);
        }
      },
    );
  }

  /// Refreshes the user profile from the server.
  /// If the user is already authenticated and a transient network error occurs,
  /// the existing user data is preserved without wiping the state.
  Future<Result<User>> refreshProfile() async {
    final result = await _restoreSessionUseCase();

    result.when(
      success: (user) {
        state = AuthState.authenticated(user: user);
      },
      error: (failure) {
        if (failure is UnauthorizedFailure) {
          state = const AuthState.unauthenticated();
        } else if (state is! AuthAuthenticated) {
          state = AuthState.sessionCheckFailed(failure: failure);
        }
      },
    );

    return result;
  }

  /// Authenticates using [username] and [password].
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = const AuthState.loading(message: 'Signing in...');

    final result = await _loginUseCase(username: username, password: password);

    return result.when(
      success: (user) {
        state = AuthState.authenticated(user: user);
        return true;
      },
      error: (failure) {
        state = AuthState.unauthenticated(message: failure.message);
        return false;
      },
    );
  }

  /// Terminates the current session, clearing secure storage tokens.
  Future<void> logout() async {
    state = const AuthState.loading(message: 'Signing out...');
    await _logoutUseCase();
    state = const AuthState.unauthenticated();
  }

  /// Called when an HTTP 401/403 or token refresh failure forces sign-out.
  void onSessionExpired([
    String message = 'Your session has expired. Please sign in again.',
  ]) {
    state = AuthState.sessionExpired(message: message);
  }
}
