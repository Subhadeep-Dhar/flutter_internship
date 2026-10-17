import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/auth/data/models/auth_tokens_model.dart';
import 'package:shopsphere/features/auth/domain/entities/auth_tokens.dart';

void main() {
  group('AuthTokensModel', () {
    test('is a subtype of AuthTokens entity', () {
      const model = AuthTokensModel(
        accessToken: 'access_123',
        refreshToken: 'refresh_123',
      );
      expect(model, isA<AuthTokens>());
    });

    test('fromJson parses accessToken and refreshToken correctly', () {
      final json = {
        'accessToken': 'jwt_access_abc',
        'refreshToken': 'jwt_refresh_xyz',
      };

      final model = AuthTokensModel.fromJson(json);

      expect(model.accessToken, 'jwt_access_abc');
      expect(model.refreshToken, 'jwt_refresh_xyz');
    });

    test('fromJson supports legacy token key fallback', () {
      final json = {'token': 'fallback_token', 'refreshToken': 'refresh_abc'};

      final model = AuthTokensModel.fromJson(json);

      expect(model.accessToken, 'fallback_token');
      expect(model.refreshToken, 'refresh_abc');
    });

    test('toJson serializes correctly', () {
      const model = AuthTokensModel(
        accessToken: 'access_1',
        refreshToken: 'refresh_1',
      );

      final json = model.toJson();

      expect(json['accessToken'], 'access_1');
      expect(json['refreshToken'], 'refresh_1');
    });
  });
}
