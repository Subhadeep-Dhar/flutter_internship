import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exceptions.dart';

/// Contract for secure local token persistence.
abstract class AuthLocalDataSource {
  /// Securely stores the access and refresh tokens.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Reads the stored access token, or returns null if not present.
  Future<String?> getAccessToken();

  /// Reads the stored refresh token, or returns null if not present.
  Future<String?> getRefreshToken();

  /// Removes all stored tokens from secure storage.
  Future<void> clearTokens();
}

/// Implementation of [AuthLocalDataSource] backed by [FlutterSecureStorage].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'shopsphere_access_token';
  static const String _refreshTokenKey = 'shopsphere_refresh_token';

  const AuthLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw CacheException(
        message: 'Failed to write auth tokens to secure storage: $e',
      );
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to read access token from secure storage: $e',
      );
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to read refresh token from secure storage: $e',
      );
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear secure storage tokens: $e',
      );
    }
  }
}
