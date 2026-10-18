import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/di/providers.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/breakpoints.dart';

/// Shared, adaptive navigation shell providing persistent top-level navigation
/// across Catalogue, Cart, and Profile.
class AppScaffoldShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffoldShell({super.key, required this.navigationShell});

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final screenType = Breakpoints.fromWidth(width);
    final isCompact = screenType == ScreenType.compact;
    final cartCount = ref.watch(cartItemCountProvider);

    if (isCompact) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Catalogue',
            ),
            NavigationDestination(
              icon: _buildCartIcon(cartCount, isSelected: false),
              selectedIcon: _buildCartIcon(cartCount, isSelected: true),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      );
    }

    // Medium (600–1024 dp) and Expanded (>1024 dp)
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: [
              const NavigationRailDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: Text('Catalogue'),
              ),
              NavigationRailDestination(
                icon: _buildCartIcon(cartCount, isSelected: false),
                selectedIcon: _buildCartIcon(cartCount, isSelected: true),
                label: const Text('Cart'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  Widget _buildCartIcon(int cartCount, {required bool isSelected}) {
    final icon = Icon(
      isSelected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
    );

    if (cartCount <= 0) {
      return icon;
    }

    final countLabel = cartCount > 99 ? '99+' : '$cartCount';

    return Badge(
      backgroundColor: AppColors.saleOrange,
      textColor: Colors.white,
      label: Text(
        countLabel,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      child: icon,
    );
  }
}
