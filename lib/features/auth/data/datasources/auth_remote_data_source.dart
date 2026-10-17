import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// Contract for authentication remote network interactions.
abstract class AuthRemoteDataSource {
  /// Authenticates credentials with DummyJSON and returns user profile and tokens.
  Future<({UserModel user, AuthTokensModel tokens})> login({
    required String username,
    required String password,
  });

  /// Fetches the authenticated user profile using [accessToken].
  Future<UserModel> getMe(String accessToken);

  /// Requests a refreshed access token using [refreshToken].
  Future<AuthTokensModel> refresh(String refreshToken);
}

/// Implementation of [AuthRemoteDataSource] using [Dio].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<({UserModel user, AuthTokensModel tokens})> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'username': username, 'password': password, 'expiresInMins': 30},
    );

    final data = response.data as Map<String, dynamic>;
    final user = UserModel.fromJson(data);
    final tokens = AuthTokensModel.fromJson(data);

    return (user: user, tokens: tokens);
  }

  @override
  Future<UserModel> getMe(String accessToken) async {
    final response = await _dio.get(
      ApiEndpoints.me,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<AuthTokensModel> refresh(String refreshToken) async {
    final response = await _dio.post(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken, 'expiresInMins': 30},
    );

    final data = response.data as Map<String, dynamic>;
    return AuthTokensModel.fromJson(data);
  }
}
