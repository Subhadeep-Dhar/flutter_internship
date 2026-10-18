import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/widgets/logout_confirmation_dialog.dart';
import 'package:shopsphere/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/controllers/auth_state.dart';
import 'package:shopsphere/features/cart/presentation/controllers/cart_notifier.dart';
import 'package:shopsphere/features/cart/presentation/controllers/cart_state.dart';

class MockAuthNotifier extends AuthNotifier {
  bool logoutCalled = false;

  @override
  AuthState build() => const AuthState.initial();

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

class MockCartNotifier extends CartNotifier {
  bool clearCartCalled = false;

  @override
  CartState build() => const CartState(status: CartStatus.ready);

  @override
  Future<void> clearCart() async {
    clearCartCalled = true;
  }
}

void main() {
  group('LogoutConfirmationDialog Widget Tests', () {
    late MockAuthNotifier mockAuthNotifier;
    late MockCartNotifier mockCartNotifier;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
      mockCartNotifier = MockCartNotifier();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => mockAuthNotifier),
          cartNotifierProvider.overrideWith(() => mockCartNotifier),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => LogoutConfirmationDialog.show(context),
                  child: const Text('Trigger Logout'),
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets(
      'renders dialog with title, message, Cancel and Log out actions',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Trigger Logout'));
        await tester.pumpAndSettle();

        expect(find.text('Log out?'), findsOneWidget);
        expect(
          find.text('Are you sure you want to log out of ShopSphere?'),
          findsOneWidget,
        );
        expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Log out'), findsOneWidget);
      },
    );

    testWidgets(
      'Cancel button dismisses dialog without calling logout or clearCart',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Trigger Logout'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Log out?'), findsNothing);
        expect(mockAuthNotifier.logoutCalled, isFalse);
        expect(mockCartNotifier.clearCartCalled, isFalse);
      },
    );

    testWidgets('Log out button calls clearCart and logout and closes dialog', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Trigger Logout'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
      await tester.pumpAndSettle();

      expect(mockCartNotifier.clearCartCalled, isTrue);
      expect(mockAuthNotifier.logoutCalled, isTrue);
      expect(find.text('Log out?'), findsNothing);
    });
  });
}
