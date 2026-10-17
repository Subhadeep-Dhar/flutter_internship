import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/network/auth_interceptor.dart';

class MockAuthTokenProvider extends Mock implements AuthTokenProvider {}

void main() {
  group('AuthInterceptor', () {
    late MockAuthTokenProvider mockTokenProvider;
    late AuthInterceptor interceptor;

    setUp(() {
      mockTokenProvider = MockAuthTokenProvider();
      interceptor = AuthInterceptor(tokenProvider: mockTokenProvider);
    });

    test(
      'attaches Bearer token header when tokenProvider yields an access token',
      () async {
        when(
          () => mockTokenProvider.getAccessToken(),
        ).thenAnswer((_) async => 'valid_access_token_123');

        final options = RequestOptions(path: '/auth/me');
        final handler = RequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(
          options.headers['Authorization'],
          'Bearer valid_access_token_123',
        );
        verify(() => mockTokenProvider.getAccessToken()).called(1);
      },
    );

    test(
      'does not attach Authorization header when tokenProvider yields null',
      () async {
        when(
          () => mockTokenProvider.getAccessToken(),
        ).thenAnswer((_) async => null);

        final options = RequestOptions(path: '/products');
        final handler = RequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(options.headers.containsKey('Authorization'), isFalse);
      },
    );

    test(
      'preserves existing custom Authorization header if already present',
      () async {
        final options = RequestOptions(
          path: '/auth/custom',
          headers: {'Authorization': 'Custom manual_token'},
        );
        final handler = RequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(options.headers['Authorization'], 'Custom manual_token');
        verifyNever(() => mockTokenProvider.getAccessToken());
      },
    );

    test('passes through cleanly when no tokenProvider is provided', () async {
      final unauthenticatedInterceptor = AuthInterceptor(tokenProvider: null);
      final options = RequestOptions(path: '/products');
      final handler = RequestInterceptorHandler();

      await unauthenticatedInterceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });
}
