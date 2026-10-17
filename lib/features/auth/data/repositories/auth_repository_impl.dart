import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// Concrete implementation of [AuthRepository] combining local secure storage
/// with remote DummyJSON authentication endpoints.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final authData = await remoteDataSource.login(
        username: username,
        password: password,
      );

      await localDataSource.saveTokens(
        accessToken: authData.tokens.accessToken,
        refreshToken: authData.tokens.refreshToken,
      );

      return Result.success(authData.user);
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      // Map DummyJSON 400 "Invalid credentials" to a clear, friendly failure message
      if (failure is ServerFailure && failure.statusCode == 400) {
        return const Result.error(
          ServerFailure(
            message: 'Invalid username or password.',
            statusCode: 400,
          ),
        );
      }
      return Result.error(failure);
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token == null || token.isEmpty) {
        return const Result.error(
          UnauthorizedFailure(message: 'No active session token found.'),
        );
      }

      final user = await remoteDataSource.getMe(token);
      return Result.success(user);
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      return Result.error(failure);
    }
  }

  @override
  Future<Result<User>> restoreSession() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token == null || token.isEmpty) {
        return const Result.error(
          UnauthorizedFailure(message: 'No stored session found.'),
        );
      }

      // Validate session against the server
      final result = await getCurrentUser();
      return result.when(
        success: (user) => Result.success(user),
        error: (failure) async {
          // If the server confirms authentication failure (expired token 401/403), wipe local tokens
          if (failure is UnauthorizedFailure) {
            await localDataSource.clearTokens();
          }
          // Note: for NetworkFailure or TimeoutFailure, local tokens are preserved
          // so the user can retry once connectivity is restored.
          return Result.error(failure);
        },
      );
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      return Result.error(failure);
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDataSource.clearTokens();
      return const Result.success(null);
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      return Result.error(failure);
    }
  }

  @override
  Future<Result<AuthTokens>> refreshTokens() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return const Result.error(
          UnauthorizedFailure(message: 'No refresh token available.'),
        );
      }

      final newTokens = await remoteDataSource.refresh(refreshToken);
      await localDataSource.saveTokens(
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken,
      );

      return Result.success(newTokens);
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      if (failure is UnauthorizedFailure) {
        await localDataSource.clearTokens();
      }
      return Result.error(failure);
    }
  }

  @override
  Future<bool> hasStoredTokens() async {
    try {
      final token = await localDataSource.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
