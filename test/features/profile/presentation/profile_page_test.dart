import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/widgets/app_error_view.dart';
import 'package:shopsphere/core/widgets/app_loading_indicator.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/controllers/auth_state.dart';
import 'package:shopsphere/features/cart/presentation/controllers/cart_notifier.dart';
import 'package:shopsphere/features/cart/presentation/controllers/cart_state.dart';
import 'package:shopsphere/features/profile/presentation/pages/profile_page.dart';

class MockAuthNotifier extends AuthNotifier {
  final AuthState initialState;
  bool refreshProfileCalled = false;

  MockAuthNotifier([this.initialState = const AuthState.initial()]);

  @override
  AuthState build() => initialState;

  @override
  Future<Result<User>> refreshProfile() async {
    refreshProfileCalled = true;
    if (initialState is AuthAuthenticated) {
      return Result.success((initialState as AuthAuthenticated).user);
    }
    return const Result.error(NetworkFailure(message: 'Network offline'));
  }

  @override
  Future<void> logout() async {}
}

class MockCartNotifier extends CartNotifier {
  @override
  CartState build() => const CartState(status: CartStatus.ready);

  @override
  Future<void> clearCart() async {}
}

void main() {
  const tFullUser = User(
    id: 1,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    gender: 'female',
    image: 'https://dummyjson.com/icon/emilys/128',
    phone: '+81 965-431-3024',
  );

  const tMinimalUser = User(
    id: 0,
    username: 'minimal_user',
    email: '',
    firstName: '',
    lastName: '',
    gender: null,
    image: null,
    phone: null,
  );

  Widget createWidgetUnderTest({
    AuthState authState = const AuthState.authenticated(user: tFullUser),
    MockAuthNotifier? notifier,
  }) {
    final mockNotifier = notifier ?? MockAuthNotifier(authState);

    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => mockNotifier),
        cartNotifierProvider.overrideWith(MockCartNotifier.new),
      ],
      child: MaterialApp(theme: AppTheme.lightTheme, home: const ProfilePage()),
    );
  }

  group('ProfilePage Widget Tests', () {
    testWidgets(
      'renders all verified /auth/me user data: name, username, email, phone, gender, ID',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.text('Emily Johnson'), findsOneWidget);
        expect(find.text('@emilys'), findsOneWidget);
        expect(find.text('emily.johnson@x.dummyjson.com'), findsOneWidget);
        expect(find.text('+81 965-431-3024'), findsOneWidget);
        expect(find.text('Female'), findsOneWidget);
        expect(find.text('#1'), findsOneWidget);
      },
    );

    testWidgets(
      'renders "Not provided" fallbacks when user fields are null or empty',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            authState: const AuthState.authenticated(user: tMinimalUser),
          ),
        );
        await tester.pump();

        expect(find.text('@minimal_user'), findsOneWidget);
        // Email, Phone, Gender, User ID all fall back to "Not provided"
        expect(find.text('Not provided'), findsAtLeastNWidgets(3));
      },
    );

    testWidgets(
      'renders AppLoadingIndicator when session is actively loading without cached user',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            authState: const AuthState.loading(message: 'Loading profile...'),
          ),
        );
        await tester.pump();

        expect(find.byType(AppLoadingIndicator), findsOneWidget);
        expect(find.text('Loading profile...'), findsOneWidget);
      },
    );

    testWidgets(
      'renders AppErrorView when session check failed without cached user and retry works',
      (tester) async {
        final mockNotifier = MockAuthNotifier(
          const AuthState.sessionCheckFailed(
            failure: NetworkFailure(
              message: 'Connection failed. Please retry.',
            ),
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            authState: mockNotifier.initialState,
            notifier: mockNotifier,
          ),
        );
        await tester.pump();

        expect(find.byType(AppErrorView), findsOneWidget);
        expect(find.text('Connection failed. Please retry.'), findsOneWidget);

        final retryBtn = find.widgetWithText(FilledButton, 'Retry');
        expect(retryBtn, findsOneWidget);
        await tester.tap(retryBtn);
        await tester.pump();

        expect(mockNotifier.refreshProfileCalled, isTrue);
      },
    );

    testWidgets(
      'tapping Log Out button opens the LogoutConfirmationDialog modal',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final logoutBtn = find.byKey(const ValueKey('profile_logout_button'));
        expect(logoutBtn, findsOneWidget);

        await tester.ensureVisible(logoutBtn);
        await tester.tap(logoutBtn);
        await tester.pumpAndSettle();

        expect(find.text('Log out?'), findsOneWidget);
        expect(
          find.text('Are you sure you want to log out of ShopSphere?'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping AppBar logout icon opens the LogoutConfirmationDialog modal',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final logoutIcon = find.byTooltip('Log out');
        expect(logoutIcon, findsOneWidget);

        await tester.tap(logoutIcon);
        await tester.pumpAndSettle();

        expect(find.text('Log out?'), findsOneWidget);
      },
    );
  });
}
