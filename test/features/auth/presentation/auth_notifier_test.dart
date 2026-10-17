import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopsphere/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:shopsphere/features/auth/presentation/controllers/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRestoreSessionUseCase extends Mock implements RestoreSessionUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  group('AuthNotifier', () {
    late MockLoginUseCase mockLoginUseCase;
    late MockRestoreSessionUseCase mockRestoreSessionUseCase;
    late MockLogoutUseCase mockLogoutUseCase;

    const testUser = User(
      id: 1,
      username: 'emilys',
      email: 'emily@example.com',
      firstName: 'Emily',
      lastName: 'Johnson',
    );

    setUp(() {
      mockLoginUseCase = MockLoginUseCase();
      mockRestoreSessionUseCase = MockRestoreSessionUseCase();
      mockLogoutUseCase = MockLogoutUseCase();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
          restoreSessionUseCaseProvider.overrideWithValue(
            mockRestoreSessionUseCase,
          ),
          logoutUseCaseProvider.overrideWithValue(mockLogoutUseCase),
        ],
      );
    }

    test('initial state is AuthInitial', () {
      final container = createContainer();
      addTearDown(container.dispose);

      expect(container.read(authNotifierProvider), const AuthState.initial());
    });

    test(
      'checkSession emits Authenticated when restoreSession succeeds',
      () async {
        when(
          () => mockRestoreSessionUseCase(),
        ).thenAnswer((_) async => const Result.success(testUser));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.checkSession();

        expect(
          container.read(authNotifierProvider),
          const AuthState.authenticated(user: testUser),
        );
      },
    );

    test(
      'checkSession emits Unauthenticated when session is not found or expired',
      () async {
        when(() => mockRestoreSessionUseCase()).thenAnswer(
          (_) async => const Result.error(
            UnauthorizedFailure(message: 'No active session'),
          ),
        );

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.checkSession();

        expect(
          container.read(authNotifierProvider),
          const AuthState.unauthenticated(),
        );
      },
    );

    test(
      'checkSession emits SessionCheckFailed on network or connectivity failure',
      () async {
        const networkFailure = NetworkFailure();
        when(
          () => mockRestoreSessionUseCase(),
        ).thenAnswer((_) async => const Result.error(networkFailure));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(authNotifierProvider.notifier);
        await notifier.checkSession();

        expect(
          container.read(authNotifierProvider),
          const AuthState.sessionCheckFailed(failure: networkFailure),
        );
      },
    );

    test(
      'login emits Authenticated and returns true on valid credentials',
      () async {
        when(
          () => mockLoginUseCase(username: 'emilys', password: 'emilyspass'),
        ).thenAnswer((_) async => const Result.success(testUser));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(authNotifierProvider.notifier);
        final success = await notifier.login(
          username: 'emilys',
          password: 'emilyspass',
        );

        expect(success, isTrue);
        expect(
          container.read(authNotifierProvider),
          const AuthState.authenticated(user: testUser),
        );
      },
    );

    test(
      'login emits Unauthenticated with message and returns false on failure',
      () async {
        const failure = ServerFailure(
          message: 'Invalid username or password.',
          statusCode: 400,
        );

        when(
          () => mockLoginUseCase(username: 'emilys', password: 'wrongpassword'),
        ).thenAnswer((_) async => const Result.error(failure));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(authNotifierProvider.notifier);
        final success = await notifier.login(
          username: 'emilys',
          password: 'wrongpassword',
        );

        expect(success, isFalse);
        expect(
          container.read(authNotifierProvider),
          const AuthState.unauthenticated(
            message: 'Invalid username or password.',
          ),
        );
      },
    );

    test('logout emits Unauthenticated after calling LogoutUseCase', () async {
      when(
        () => mockLogoutUseCase(),
      ).thenAnswer((_) async => const Result.success(null));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.logout();

      expect(
        container.read(authNotifierProvider),
        const AuthState.unauthenticated(),
      );
      verify(() => mockLogoutUseCase()).called(1);
    });

    test('onSessionExpired sets AuthSessionExpired state', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authNotifierProvider.notifier);
      notifier.onSessionExpired('Session expired by server.');

      expect(
        container.read(authNotifierProvider),
        const AuthState.sessionExpired(message: 'Session expired by server.'),
      );
    });
  });
}
