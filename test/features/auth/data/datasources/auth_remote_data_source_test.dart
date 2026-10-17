import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('AuthRemoteDataSourceImpl', () {
    late MockDio mockDio;
    late AuthRemoteDataSourceImpl dataSource;

    setUp(() {
      mockDio = MockDio();
      dataSource = AuthRemoteDataSourceImpl(mockDio);
    });

    test('login sends correct payload and parses user and tokens', () async {
      final responseData = {
        'id': 1,
        'username': 'emilys',
        'email': 'emily.johnson@x.dummyjson.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'gender': 'female',
        'image': 'https://dummyjson.com/icon/emilys/128',
        'accessToken': 'access_jwt',
        'refreshToken': 'refresh_jwt',
      };

      when(
        () => mockDio.post(
          ApiEndpoints.login,
          data: {
            'username': 'emilys',
            'password': 'emilyspass',
            'expiresInMins': 30,
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.login),
          statusCode: 200,
          data: responseData,
        ),
      );

      final result = await dataSource.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(result.user.username, 'emilys');
      expect(result.user.id, 1);
      expect(result.tokens.accessToken, 'access_jwt');
      expect(result.tokens.refreshToken, 'refresh_jwt');
    });

    test('getMe sends Bearer token in options and returns UserModel', () async {
      final responseData = {
        'id': 1,
        'username': 'emilys',
        'email': 'emily.johnson@x.dummyjson.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'phone': '+81 965-431-3024',
      };

      when(
        () => mockDio.get(ApiEndpoints.me, options: any(named: 'options')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.me),
          statusCode: 200,
          data: responseData,
        ),
      );

      final user = await dataSource.getMe('valid_token');

      expect(user.username, 'emilys');
      expect(user.phone, '+81 965-431-3024');
    });

    test('refresh sends refreshToken and parses AuthTokensModel', () async {
      final responseData = {
        'accessToken': 'new_access_token',
        'refreshToken': 'new_refresh_token',
      };

      when(
        () => mockDio.post(
          ApiEndpoints.refresh,
          data: {'refreshToken': 'old_refresh_token', 'expiresInMins': 30},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.refresh),
          statusCode: 200,
          data: responseData,
        ),
      );

      final tokens = await dataSource.refresh('old_refresh_token');

      expect(tokens.accessToken, 'new_access_token');
      expect(tokens.refreshToken, 'new_refresh_token');
    });
  });
}
