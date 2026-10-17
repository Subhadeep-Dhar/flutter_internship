import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('AuthLocalDataSourceImpl', () {
    late MockFlutterSecureStorage mockStorage;
    late AuthLocalDataSourceImpl dataSource;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      dataSource = AuthLocalDataSourceImpl(mockStorage);
    });

    test(
      'saveTokens writes accessToken and refreshToken to secure storage',
      () async {
        when(
          () => mockStorage.write(
            key: 'shopsphere_access_token',
            value: 'test_access',
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockStorage.write(
            key: 'shopsphere_refresh_token',
            value: 'test_refresh',
          ),
        ).thenAnswer((_) async {});

        await dataSource.saveTokens(
          accessToken: 'test_access',
          refreshToken: 'test_refresh',
        );

        verify(
          () => mockStorage.write(
            key: 'shopsphere_access_token',
            value: 'test_access',
          ),
        ).called(1);
        verify(
          () => mockStorage.write(
            key: 'shopsphere_refresh_token',
            value: 'test_refresh',
          ),
        ).called(1);
      },
    );

    test('getAccessToken reads from correct storage key', () async {
      when(
        () => mockStorage.read(key: 'shopsphere_access_token'),
      ).thenAnswer((_) async => 'stored_token');

      final result = await dataSource.getAccessToken();

      expect(result, 'stored_token');
      verify(() => mockStorage.read(key: 'shopsphere_access_token')).called(1);
    });

    test('getRefreshToken reads from correct storage key', () async {
      when(
        () => mockStorage.read(key: 'shopsphere_refresh_token'),
      ).thenAnswer((_) async => 'stored_refresh');

      final result = await dataSource.getRefreshToken();

      expect(result, 'stored_refresh');
      verify(() => mockStorage.read(key: 'shopsphere_refresh_token')).called(1);
    });

    test('clearTokens deletes both token keys from secure storage', () async {
      when(
        () => mockStorage.delete(key: 'shopsphere_access_token'),
      ).thenAnswer((_) async {});
      when(
        () => mockStorage.delete(key: 'shopsphere_refresh_token'),
      ).thenAnswer((_) async {});

      await dataSource.clearTokens();

      verify(
        () => mockStorage.delete(key: 'shopsphere_access_token'),
      ).called(1);
      verify(
        () => mockStorage.delete(key: 'shopsphere_refresh_token'),
      ).called(1);
    });

    test('throws CacheException when storage operation throws', () async {
      when(
        () => mockStorage.read(key: 'shopsphere_access_token'),
      ).thenThrow(Exception('Storage error'));

      expect(() => dataSource.getAccessToken(), throwsA(isA<CacheException>()));
    });
  });
}
