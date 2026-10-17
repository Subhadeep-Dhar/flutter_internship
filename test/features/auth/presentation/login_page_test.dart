import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/controllers/auth_state.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';

class FakeAuthNotifier extends AuthNotifier {
  final AuthState initialState;

  FakeAuthNotifier([this.initialState = const AuthState.unauthenticated()]);

  @override
  AuthState build() => initialState;

  @override
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    return true;
  }
}

void main() {
  Widget createWidgetUnderTest({
    AuthState state = const AuthState.unauthenticated(),
  }) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => FakeAuthNotifier(state)),
      ],
      child: MaterialApp(theme: AppTheme.lightTheme, home: const LoginPage()),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('renders login form with fields and sign-in button', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Welcome to ShopSphere'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('validates empty inputs on submit', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap Sign In without filling inputs
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('validates minimum field lengths', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).first, 'ab');
      await tester.enterText(find.byType(TextFormField).last, '12');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(
        find.text('Username must be at least 3 characters'),
        findsOneWidget,
      );
      expect(
        find.text('Password must be at least 4 characters'),
        findsOneWidget,
      );
    });

    testWidgets('toggles password visibility on icon tap', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find password field
      final passwordFieldFinder = find.byType(TextFormField).last;
      TextField passwordField = tester.widget<TextField>(
        find.descendant(
          of: passwordFieldFinder,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.obscureText, isTrue);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      passwordField = tester.widget<TextField>(
        find.descendant(
          of: passwordFieldFinder,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.obscureText, isFalse);
    });

    testWidgets(
      'displays inline error banner when state is unauthenticated with message',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            state: const AuthState.unauthenticated(
              message: 'Invalid username or password.',
            ),
          ),
        );

        expect(find.text('Invalid username or password.'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      },
    );

    testWidgets('displays loading indicator on submit button when loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          state: const AuthState.loading(message: 'Signing in...'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
