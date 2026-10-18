import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/data/models/auth_tokens_model.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  group('AuthRepositoryImpl', () {
    late MockAuthRemoteDataSource mockRemote;
    late MockAuthLocalDataSource mockLocal;
    late AuthRepositoryImpl repository;

    const testUser = UserModel(
      id: 1,
      username: 'emilys',
      email: 'emily@example.com',
      firstName: 'Emily',
      lastName: 'Johnson',
    );

    const testTokens = AuthTokensModel(
      accessToken: 'access_abc',
      refreshToken: 'refresh_xyz',
    );

    setUp(() {
      mockRemote = MockAuthRemoteDataSource();
      mockLocal = MockAuthLocalDataSource();
      repository = AuthRepositoryImpl(
        remoteDataSource: mockRemote,
        localDataSource: mockLocal,
      );
    });

    group('login', () {
      test(
        'persists tokens and returns User on success (enriching with getMe)',
        () async {
          const fullUser = UserModel(
            id: 1,
            username: 'emilys',
            email: 'emily@example.com',
            firstName: 'Emily',
            lastName: 'Johnson',
            phone: '+81 965-431-3024',
          );

          when(
            () => mockRemote.login(username: 'emilys', password: 'emilyspass'),
          ).thenAnswer((_) async => (user: testUser, tokens: testTokens));

          when(
            () => mockRemote.getMe('access_abc'),
          ).thenAnswer((_) async => fullUser);

          when(
            () => mockLocal.saveTokens(
              accessToken: 'access_abc',
              refreshToken: 'refresh_xyz',
            ),
          ).thenAnswer((_) async {});

          final result = await repository.login(
            username: 'emilys',
            password: 'emilyspass',
          );

          expect(result, isA<Success>());
          expect(result.dataOrNull, fullUser);
          expect(result.dataOrNull?.phone, '+81 965-431-3024');
          verify(
            () => mockLocal.saveTokens(
              accessToken: 'access_abc',
              refreshToken: 'refresh_xyz',
            ),
          ).called(1);
        },
      );

      test('falls back to login user if getMe fails after login', () async {
        when(
          () => mockRemote.login(username: 'emilys', password: 'emilyspass'),
        ).thenAnswer((_) async => (user: testUser, tokens: testTokens));

        when(
          () => mockRemote.getMe('access_abc'),
        ).thenThrow(Exception('Transient timeout'));

        when(
          () => mockLocal.saveTokens(
            accessToken: 'access_abc',
            refreshToken: 'refresh_xyz',
          ),
        ).thenAnswer((_) async {});

        final result = await repository.login(
          username: 'emilys',
          password: 'emilyspass',
        );

        expect(result, isA<Success>());
        expect(result.dataOrNull, testUser);
      });

      test('maps 400 Invalid credentials to user-friendly failure', () async {
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 400,
            data: {'message': 'Invalid credentials'},
          ),
        );

        when(
          () => mockRemote.login(username: 'emilys', password: 'wrong'),
        ).thenThrow(dioException);

        final result = await repository.login(
          username: 'emilys',
          password: 'wrong',
        );

        expect(result, isA<Error>());
        final failure = result.failureOrNull;
        expect(failure, isA<ServerFailure>());
        expect(failure?.message, 'Invalid username or password.');
        expect(failure?.statusCode, 400);
        verifyNever(
          () => mockLocal.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        );
      });

      test('maps SocketException to NetworkFailure', () async {
        when(
          () => mockRemote.login(username: 'emilys', password: 'pass'),
        ).thenThrow(const SocketException('No route to host'));

        final result = await repository.login(
          username: 'emilys',
          password: 'pass',
        );

        expect(result, isA<Error>());
        expect(result.failureOrNull, isA<NetworkFailure>());
      });
    });

    group('restoreSession', () {
      test(
        'returns UnauthorizedFailure if no tokens exist in storage',
        () async {
          when(() => mockLocal.getAccessToken()).thenAnswer((_) async => null);

          final result = await repository.restoreSession();

          expect(result, isA<Error>());
          expect(result.failureOrNull, isA<UnauthorizedFailure>());
          verifyNever(() => mockRemote.getMe(any()));
        },
      );

      test('returns validated user when token is valid', () async {
        when(
          () => mockLocal.getAccessToken(),
        ).thenAnswer((_) async => 'stored_token');
        when(
          () => mockRemote.getMe('stored_token'),
        ).thenAnswer((_) async => testUser);

        final result = await repository.restoreSession();

        expect(result, isA<Success>());
        expect(result.dataOrNull, testUser);
      });

      test(
        'clears local tokens and returns error if token is expired (401)',
        () async {
          when(
            () => mockLocal.getAccessToken(),
          ).thenAnswer((_) async => 'expired_token');
          when(() => mockLocal.clearTokens()).thenAnswer((_) async {});

          final dio401 = DioException(
            requestOptions: RequestOptions(path: '/auth/me'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/auth/me'),
              statusCode: 401,
              data: {'message': 'Token expired'},
            ),
          );

          when(() => mockRemote.getMe('expired_token')).thenThrow(dio401);

          final result = await repository.restoreSession();

          expect(result, isA<Error>());
          expect(result.failureOrNull, isA<UnauthorizedFailure>());
          verify(() => mockLocal.clearTokens()).called(1);
        },
      );

      test(
        'preserves local tokens when session validation fails due to network outage',
        () async {
          when(
            () => mockLocal.getAccessToken(),
          ).thenAnswer((_) async => 'valid_token');
          when(
            () => mockRemote.getMe('valid_token'),
          ).thenThrow(const SocketException('Failed host lookup'));

          final result = await repository.restoreSession();

          expect(result, isA<Error>());
          expect(result.failureOrNull, isA<NetworkFailure>());
          verifyNever(() => mockLocal.clearTokens());
        },
      );
    });

    group('logout', () {
      test('clears local storage tokens and returns success', () async {
        when(() => mockLocal.clearTokens()).thenAnswer((_) async {});

        final result = await repository.logout();

        expect(result, isA<Success>());
        verify(() => mockLocal.clearTokens()).called(1);
      });
    });

    group('refreshTokens', () {
      test(
        'refreshes and saves tokens when valid refresh token exists',
        () async {
          when(
            () => mockLocal.getRefreshToken(),
          ).thenAnswer((_) async => 'old_refresh');
          when(
            () => mockRemote.refresh('old_refresh'),
          ).thenAnswer((_) async => testTokens);
          when(
            () => mockLocal.saveTokens(
              accessToken: testTokens.accessToken,
              refreshToken: testTokens.refreshToken,
            ),
          ).thenAnswer((_) async {});

          final result = await repository.refreshTokens();

          expect(result, isA<Success>());
          expect(result.dataOrNull, testTokens);
          verify(
            () => mockLocal.saveTokens(
              accessToken: testTokens.accessToken,
              refreshToken: testTokens.refreshToken,
            ),
          ).called(1);
        },
      );

      test('clears tokens and returns error if refresh returns 403', () async {
        when(
          () => mockLocal.getRefreshToken(),
        ).thenAnswer((_) async => 'bad_refresh');
        when(() => mockLocal.clearTokens()).thenAnswer((_) async {});

        final dio403 = DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            statusCode: 403,
            data: {'message': 'Invalid refresh token'},
          ),
        );

        when(() => mockRemote.refresh('bad_refresh')).thenThrow(dio403);

        final result = await repository.refreshTokens();

        expect(result, isA<Error>());
        expect(result.failureOrNull, isA<UnauthorizedFailure>());
        verify(() => mockLocal.clearTokens()).called(1);
      });
    });
  });
}
