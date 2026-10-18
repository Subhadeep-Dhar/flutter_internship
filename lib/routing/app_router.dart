import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/di/providers.dart';
import '../features/auth/presentation/controllers/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/products/presentation/pages/home_page.dart';
import '../features/products/presentation/pages/product_detail_page.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

/// Centralized route paths for ShopSphere.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String productDetails = '/product/:id';
  static const String cart = '/cart';
  static const String profile = '/profile';

  /// Helper to generate the path for a specific product by ID.
  static String productDetail(int id) => '/product/$id';
}

/// A [ChangeNotifier] bridge that triggers GoRouter redirect re-evaluations
/// whenever the [authNotifierProvider] state changes.
class _AuthRouterListenable extends ChangeNotifier {
  _AuthRouterListenable(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      notifyListeners();
    });
  }
}

/// Riverpod provider delivering the application's [GoRouter] instance.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthRouterListenable(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authListenable,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        name: 'productDetails',
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '';
          final id = int.tryParse(idStr) ?? 0;
          return ProductDetailPage(productId: id);
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authNotifierProvider);
      final isGoingToSplash = state.matchedLocation == AppRoutes.splash;
      final isGoingToLogin = state.matchedLocation == AppRoutes.login;

      // 1. If session check failed with a recoverable network/server error on splash,
      // stay on splash so the user can review the error and tap Retry.
      if (authState is AuthSessionCheckFailed && isGoingToSplash) {
        return null;
      }

      // 2. While initial or verifying session on splash, stay on splash.
      if ((authState is AuthInitial || authState is AuthLoading) &&
          isGoingToSplash) {
        return null;
      }

      // 3. Authenticated users:
      if (authState is AuthAuthenticated) {
        // Prevent authenticated users from accessing login or splash
        if (isGoingToSplash || isGoingToLogin) {
          return AppRoutes.home;
        }
        return null;
      }

      // 4. Unauthenticated or session-expired users:
      if (authState is AuthUnauthenticated || authState is AuthSessionExpired) {
        // Prevent access to protected routes
        if (!isGoingToLogin) {
          return AppRoutes.login;
        }
        return null;
      }

      return null;
    },
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
});
