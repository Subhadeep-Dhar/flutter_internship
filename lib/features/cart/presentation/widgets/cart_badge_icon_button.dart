import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/app_router.dart';

/// Reusable AppBar action button displaying a shopping cart icon with a real-time
/// badge indicating total items in the cart.
class CartBadgeIconButton extends ConsumerWidget {
  final Color? color;

  const CartBadgeIconButton({super.key, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartItemCountProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: itemCount > 0
          ? 'Shopping cart with $itemCount items'
          : 'Shopping cart empty',
      button: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            color:
                color ??
                (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            tooltip: 'Shopping Cart',
            constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
            onPressed: () {
              context.push(AppRoutes.cart);
            },
          ),
          if (itemCount > 0)
            Positioned(
              top: 6.0,
              right: 6.0,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSaleOrange
                        : AppColors.saleOrange,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.ivorySurface,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18.0,
                    minHeight: 18.0,
                  ),
                  child: Center(
                    child: Text(
                      itemCount > 99 ? '99+' : '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
