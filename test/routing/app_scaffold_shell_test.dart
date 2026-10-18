import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/routing/app_scaffold_shell.dart';

void main() {
  group('AppScaffoldShell & Persistent Navigation Widget Tests', () {
    GoRouter createTestRouter() {
      return GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                AppScaffoldShell(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Catalogue Screen Content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/cart',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Cart Screen Content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/profile',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Profile Screen Content')),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    Widget createWidgetUnderTest({
      required GoRouter router,
      int cartCount = 0,
    }) {
      return ProviderScope(
        overrides: [cartItemCountProvider.overrideWithValue(cartCount)],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      );
    }

    testWidgets(
      'compact width (<600 dp) renders bottom NavigationBar across all 3 destinations',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final router = createTestRouter();
        await tester.pumpWidget(
          createWidgetUnderTest(router: router, cartCount: 3),
        );
        await tester.pumpAndSettle();

        // 1. Initial Catalogue destination: NavigationBar is visible
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Catalogue Screen Content'), findsOneWidget);

        // 2. Switch to Cart: NavigationBar remains visible
        await tester.tap(find.text('Cart'));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Cart Screen Content'), findsOneWidget);

        // 3. Switch to Profile: NavigationBar remains visible
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Profile Screen Content'), findsOneWidget);
      },
    );

    testWidgets(
      'medium width (600-1024 dp) renders persistent NavigationRail without NavigationBar',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final router = createTestRouter();
        await tester.pumpWidget(createWidgetUnderTest(router: router));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.text('Catalogue Screen Content'), findsOneWidget);

        // Navigation to Cart maintains NavigationRail
        await tester.tap(find.text('Cart'));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Cart Screen Content'), findsOneWidget);
      },
    );

    testWidgets(
      'cart destination badge reflects reactive count and caps at 99+',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Test with 5 items
        final router1 = createTestRouter();
        await tester.pumpWidget(
          createWidgetUnderTest(router: router1, cartCount: 5),
        );
        await tester.pumpAndSettle();

        expect(find.text('5'), findsOneWidget);

        // Test with 120 items -> should display 99+
        final router2 = createTestRouter();
        await tester.pumpWidget(
          createWidgetUnderTest(router: router2, cartCount: 120),
        );
        await tester.pumpAndSettle();

        expect(find.text('99+'), findsOneWidget);
      },
    );
  });
}
