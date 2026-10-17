import '../../../../core/error/result.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';

/// Pure Dart contract defining the authentication repository operations.
abstract class AuthRepository {
  /// Authenticates the user with [username] and [password].
  ///
  /// On success, persists the returned tokens and returns the authenticated [User].
  Future<Result<User>> login({
    required String username,
    required String password,
  });

  /// Fetches the currently authenticated profile from the backend.
  Future<Result<User>> getCurrentUser();

  /// Reads stored credentials and validates the session against the server.
  ///
  /// Returns [Success] with [User] if credentials are valid, or [Error]
  /// if no tokens exist, tokens are expired, or the network is unreachable.
  Future<Result<User>> restoreSession();

  /// Logs out the user, clearing local tokens and cached credentials.
  Future<Result<void>> logout();

  /// Refreshes the active session tokens using the stored refresh token.
  Future<Result<AuthTokens>> refreshTokens();

  /// Returns true if valid tokens exist in local secure storage.
  Future<bool> hasStoredTokens();
}
