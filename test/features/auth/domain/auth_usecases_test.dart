import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/restore_session_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('Auth Domain UseCases', () {
    late MockAuthRepository mockRepository;

    const testUser = User(
      id: 1,
      username: 'emilys',
      email: 'emily@example.com',
      firstName: 'Emily',
      lastName: 'Johnson',
    );

    setUp(() {
      mockRepository = MockAuthRepository();
    });

    test('LoginUseCase delegates credentials to repository', () async {
      when(
        () => mockRepository.login(username: 'emilys', password: 'emilyspass'),
      ).thenAnswer((_) async => const Result.success(testUser));

      final useCase = LoginUseCase(mockRepository);
      final result = await useCase(username: 'emilys', password: 'emilyspass');

      expect(result.dataOrNull, testUser);
      verify(
        () => mockRepository.login(username: 'emilys', password: 'emilyspass'),
      ).called(1);
    });

    test('RestoreSessionUseCase calls repository.restoreSession', () async {
      when(
        () => mockRepository.restoreSession(),
      ).thenAnswer((_) async => const Result.success(testUser));

      final useCase = RestoreSessionUseCase(mockRepository);
      final result = await useCase();

      expect(result.dataOrNull, testUser);
      verify(() => mockRepository.restoreSession()).called(1);
    });

    test('LogoutUseCase calls repository.logout', () async {
      when(
        () => mockRepository.logout(),
      ).thenAnswer((_) async => const Result.success(null));

      final useCase = LogoutUseCase(mockRepository);
      final result = await useCase();

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.logout()).called(1);
    });
  });
}
