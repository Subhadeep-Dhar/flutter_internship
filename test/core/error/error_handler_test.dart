import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/error_handler.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';

void main() {
  group('ErrorHandler', () {
    final requestOptions = RequestOptions(path: '/test');

    test('maps connection, send, and receive timeouts to TimeoutFailure', () {
      final connTimeout = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );
      final sendTimeout = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.sendTimeout,
      );
      final recvTimeout = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.receiveTimeout,
      );

      expect(ErrorHandler.handle(connTimeout), isA<TimeoutFailure>());
      expect(ErrorHandler.handle(sendTimeout), isA<TimeoutFailure>());
      expect(ErrorHandler.handle(recvTimeout), isA<TimeoutFailure>());
    });

    test('maps connectionError to NetworkFailure', () {
      final connError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );

      final failure = ErrorHandler.handle(connError);
      expect(failure, isA<NetworkFailure>());
    });

    test(
      'maps badResponse with 400 and message to ServerFailure with custom message',
      () {
        final dioException = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 400,
            data: {'message': 'Invalid credentials'},
          ),
        );

        final failure = ErrorHandler.handle(dioException);
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Invalid credentials');
        expect(failure.statusCode, 400);
      },
    );

    test('maps badResponse with 401 to UnauthorizedFailure', () {
      final dioException = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'message': 'Token expired'},
        ),
      );

      final failure = ErrorHandler.handle(dioException);
      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'Token expired');
      expect(failure.statusCode, 401);
    });

    test(
      'maps badResponse with 403 to UnauthorizedFailure with status 403',
      () {
        final dioException = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 403,
            data: {'message': 'Refresh token invalid'},
          ),
        );

        final failure = ErrorHandler.handle(dioException);
        expect(failure, isA<UnauthorizedFailure>());
        expect(failure.message, 'Refresh token invalid');
        expect(failure.statusCode, 403);
      },
    );

    test('maps badResponse with 404 to NotFoundFailure', () {
      final dioException = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 404,
          data: {'message': "Product with id '9999' not found"},
        ),
      );

      final failure = ErrorHandler.handle(dioException);
      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, "Product with id '9999' not found");
      expect(failure.statusCode, 404);
    });

    test('maps badResponse with 500 to ServerFailure with status code', () {
      final dioException = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: requestOptions, statusCode: 500),
      );

      final failure = ErrorHandler.handle(dioException);
      expect(failure, isA<ServerFailure>());
      expect(failure.statusCode, 500);
    });

    test('maps SocketException to NetworkFailure', () {
      const socketException = SocketException('Failed host lookup');
      final failure = ErrorHandler.handle(socketException);

      expect(failure, isA<NetworkFailure>());
    });

    test('maps FormatException to SerializationFailure', () {
      const formatException = FormatException('Unexpected character');
      final failure = ErrorHandler.handle(formatException);

      expect(failure, isA<SerializationFailure>());
    });

    test(
      'maps domain AppException types directly to corresponding Failures',
      () {
        const cacheEx = CacheException(message: 'Disk full');
        final cacheFailure = ErrorHandler.handle(cacheEx);

        expect(cacheFailure, isA<CacheFailure>());
        expect(cacheFailure.message, 'Disk full');

        const notFoundEx = NotFoundException(message: 'Item missing');
        final notFoundFailure = ErrorHandler.handle(notFoundEx);

        expect(notFoundFailure, isA<NotFoundFailure>());
        expect(notFoundFailure.message, 'Item missing');
      },
    );

    test('returns the same failure if already a Failure instance', () {
      const existing = NetworkFailure();
      expect(ErrorHandler.handle(existing), same(existing));
    });
  });
}
