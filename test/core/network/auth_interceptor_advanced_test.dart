import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/network/auth_interceptor.dart';

class MockAuthTokenProvider extends Mock implements AuthTokenProvider {}

class MockDio extends Mock implements Dio {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeResponse extends Fake implements Response<dynamic> {}

class FakeDioException extends Fake implements DioException {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeResponse());
    registerFallbackValue(FakeDioException());
  });

  group('AuthInterceptor Advanced - Refresh & Bounded Retry', () {
    late MockAuthTokenProvider mockTokenProvider;
    late MockDio mockDio;
    late AuthInterceptor interceptor;

    setUp(() {
      mockTokenProvider = MockAuthTokenProvider();
      mockDio = MockDio();
      interceptor = AuthInterceptor(
        tokenProvider: mockTokenProvider,
        dio: mockDio,
      );
    });

    test('onRequest skips token injection for public auth endpoints', () async {
      final loginOptions = RequestOptions(path: '/auth/login');
      final refreshOptions = RequestOptions(path: '/auth/refresh');

      final handler1 = MockRequestInterceptorHandler();
      final handler2 = MockRequestInterceptorHandler();

      await interceptor.onRequest(loginOptions, handler1);
      await interceptor.onRequest(refreshOptions, handler2);

      expect(loginOptions.headers.containsKey('Authorization'), isFalse);
      expect(refreshOptions.headers.containsKey('Authorization'), isFalse);
      verifyNever(() => mockTokenProvider.getAccessToken());
      verify(() => handler1.next(loginOptions)).called(1);
      verify(() => handler2.next(refreshOptions)).called(1);
    });

    test(
      'onError does not trigger refresh when 401 occurs on login or refresh endpoint',
      () async {
        final loginOptions = RequestOptions(path: '/auth/login');
        final dioError = DioException(
          requestOptions: loginOptions,
          response: Response(requestOptions: loginOptions, statusCode: 401),
        );

        final handler = MockErrorInterceptorHandler();
        await interceptor.onError(dioError, handler);

        verifyNever(() => mockTokenProvider.refreshToken());
        verify(() => handler.next(dioError)).called(1);
      },
    );

    test(
      'onError triggers single-flight refresh and retries request on 401',
      () async {
        when(
          () => mockTokenProvider.getRefreshToken(),
        ).thenAnswer((_) async => 'valid_refresh_token');
        when(
          () => mockTokenProvider.refreshToken(),
        ).thenAnswer((_) async => true);
        when(
          () => mockTokenProvider.getAccessToken(),
        ).thenAnswer((_) async => 'new_access_token_456');

        final requestOptions = RequestOptions(path: '/products');
        final dio401 = DioException(
          requestOptions: requestOptions,
          response: Response(requestOptions: requestOptions, statusCode: 401),
        );

        final expectedResponse = Response(
          requestOptions: requestOptions,
          statusCode: 200,
          data: {'products': []},
        );

        when(() => mockDio.fetch(any())).thenAnswer((invocation) async {
          final options = invocation.positionalArguments[0] as RequestOptions;
          expect(options.extra['x-shopsphere-retry'], isTrue);
          expect(
            options.headers['Authorization'],
            'Bearer new_access_token_456',
          );
          return expectedResponse;
        });

        final handler = MockErrorInterceptorHandler();
        await interceptor.onError(dio401, handler);

        verify(() => mockTokenProvider.refreshToken()).called(1);
        verify(() => mockDio.fetch(any())).called(1);
        verify(() => handler.resolve(expectedResponse)).called(1);
      },
    );

    test(
      'onError prevents retry loops when a retried request fails again with 401',
      () async {
        final retryOptions = RequestOptions(
          path: '/products',
          extra: {'x-shopsphere-retry': true},
        );
        final dio401 = DioException(
          requestOptions: retryOptions,
          response: Response(requestOptions: retryOptions, statusCode: 401),
        );

        final handler = MockErrorInterceptorHandler();
        await interceptor.onError(dio401, handler);

        verifyNever(() => mockTokenProvider.refreshToken());
        verifyNever(() => mockDio.fetch(any()));
        verify(() => handler.next(dio401)).called(1);
      },
    );

    test(
      'onError executes single-flight refresh when multiple concurrent 401s occur',
      () async {
        final refreshCompleter = Completer<bool>();

        when(
          () => mockTokenProvider.getRefreshToken(),
        ).thenAnswer((_) async => 'refresh_token_123');
        when(
          () => mockTokenProvider.refreshToken(),
        ).thenAnswer((_) => refreshCompleter.future);
        when(
          () => mockTokenProvider.getAccessToken(),
        ).thenAnswer((_) async => 'new_shared_access_token');

        final req1 = RequestOptions(path: '/products/1');
        final req2 = RequestOptions(path: '/products/2');

        final err1 = DioException(
          requestOptions: req1,
          response: Response(requestOptions: req1, statusCode: 401),
        );
        final err2 = DioException(
          requestOptions: req2,
          response: Response(requestOptions: req2, statusCode: 401),
        );

        final resp1 = Response(requestOptions: req1, statusCode: 200);
        final resp2 = Response(requestOptions: req2, statusCode: 200);

        when(() => mockDio.fetch(any())).thenAnswer((inv) async {
          final opt = inv.positionalArguments[0] as RequestOptions;
          if (opt.path == '/products/1') return resp1;
          return resp2;
        });

        final handler1 = MockErrorInterceptorHandler();
        final handler2 = MockErrorInterceptorHandler();

        // Fire both 401 errors concurrently
        final future1 = interceptor.onError(err1, handler1);
        final future2 = interceptor.onError(err2, handler2);

        // Complete the single refresh operation
        refreshCompleter.complete(true);

        await Future.wait([future1, future2]);

        // Assert that refreshToken was called EXACTLY ONCE for both concurrent requests
        verify(() => mockTokenProvider.refreshToken()).called(1);
        verify(() => mockDio.fetch(any())).called(2);
        verify(() => handler1.resolve(resp1)).called(1);
        verify(() => handler2.resolve(resp2)).called(1);
      },
    );

    test(
      'onError calls onAuthenticationExpired and passes error when refresh fails',
      () async {
        when(
          () => mockTokenProvider.getRefreshToken(),
        ).thenAnswer((_) async => 'expired_refresh');
        when(
          () => mockTokenProvider.refreshToken(),
        ).thenAnswer((_) async => false);
        when(
          () => mockTokenProvider.onAuthenticationExpired(),
        ).thenAnswer((_) async {});

        final req = RequestOptions(path: '/products/1');
        final err = DioException(
          requestOptions: req,
          response: Response(requestOptions: req, statusCode: 401),
        );

        final handler = MockErrorInterceptorHandler();
        await interceptor.onError(err, handler);

        verify(() => mockTokenProvider.onAuthenticationExpired()).called(1);
        verifyNever(() => mockDio.fetch(any()));
        verify(() => handler.next(err)).called(1);
      },
    );
  });
}
