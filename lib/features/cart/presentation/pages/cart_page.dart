import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../controllers/cart_notifier.dart';
import '../controllers/cart_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/checkout_success_dialog.dart';
import '../widgets/order_summary_card.dart';

/// Full-featured, responsive shopping cart page displaying active items,
/// quantity management, price calculations, and simulated checkout.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  void _showClearConfirmation(
    BuildContext context,
    CartNotifier notifier,
    bool isDark,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.ivorySurface,
          title: const Text('Clear Cart?'),
          content: const Text(
            'Are you sure you want to remove all items from your shopping cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                notifier.clearCart();
              },
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkSaleOrange
                    : AppColors.saleOrange,
              ),
              child: const Text('Clear Cart'),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutSuccessModal(
    BuildContext context,
    WidgetRef ref,
    CartState state,
  ) {
    final result = state.checkoutResult;
    if (result == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CheckoutSuccessDialog(
          result: result,
          onDismiss: () {
            Navigator.of(dialogContext).pop();
            ref.read(cartNotifierProvider.notifier).dismissCheckoutSuccess();
            context.go('/home');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(cartNotifierProvider);
    final notifier = ref.read(cartNotifierProvider.notifier);

    // Listen for checkout success to trigger confirmation modal
    ref.listen<CartState>(cartNotifierProvider, (previous, next) {
      if (next.isCheckoutSuccess && next.checkoutResult != null) {
        _showCheckoutSuccessModal(context, ref, next);
      }
    });

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.ivoryBackground,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          if (state.cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
              constraints: const BoxConstraints(
                minWidth: 48.0,
                minHeight: 48.0,
              ),
              onPressed: () =>
                  _showClearConfirmation(context, notifier, isDark),
            ),
        ],
      ),
      body: SafeArea(
        child: switch (state.status) {
          _ when state.isLoading && state.cart.isEmpty => const Center(
            child: AppLoadingIndicator(message: 'Loading cart...'),
          ),
          _ when state.cart.isEmpty => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppEmptyView(
                icon: Icons.shopping_bag_outlined,
                title: 'Your cart is empty',
                message:
                    'Looks like you haven\'t added any products to your cart yet.',
                actionLabel: 'Explore Products',
                onAction: () => context.go('/home'),
              ),
            ),
          ),
          _ => LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= Breakpoints.mediumMinWidth;

              return Column(
                children: [
                  // Error Banner if present
                  if (state.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSaleOrange.withValues(alpha: 0.2)
                            : AppColors.saleOrangeContainer,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkSaleOrange
                              : AppColors.saleOrange,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 20.0,
                            color: isDark
                                ? AppColors.darkSaleOrange
                                : AppColors.saleOrange,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.onSaleOrangeContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18.0),
                            tooltip: 'Dismiss message',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32.0,
                              minHeight: 32.0,
                            ),
                            onPressed: () => notifier.clearErrorMessage(),
                          ),
                        ],
                      ),
                    ),

                  // Responsive Body
                  Expanded(
                    child: isWide
                        ? _WideCartLayout(state: state, notifier: notifier)
                        : _CompactCartLayout(state: state, notifier: notifier),
                  ),
                ],
              );
            },
          ),
        },
      ),
    );
  }
}

/// Compact vertical cart layout for phones.
class _CompactCartLayout extends StatelessWidget {
  final CartState state;
  final CartNotifier notifier;

  const _CompactCartLayout({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        ...state.cart.items.map((item) {
          return CartItemCard(
            key: ValueKey(item.productId),
            item: item,
            onIncrement: () => notifier.incrementQuantity(item.productId),
            onDecrement: () => notifier.decrementQuantity(item.productId),
            onRemove: () => notifier.removeItem(item.productId),
          );
        }),
        AppSpacing.gapMd,
        OrderSummaryCard(
          cart: state.cart,
          isCheckingOut: state.isCheckingOut,
          onCheckout: () => notifier.checkout(),
        ),
      ],
    );
  }
}

/// Dual-column side-by-side cart layout for tablets and desktops.
class _WideCartLayout extends StatelessWidget {
  final CartState state;
  final CartNotifier notifier;

  const _WideCartLayout({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Items List (flex 3)
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: state.cart.items.length,
              itemBuilder: (context, index) {
                final item = state.cart.items[index];
                return CartItemCard(
                  key: ValueKey(item.productId),
                  item: item,
                  onIncrement: () => notifier.incrementQuantity(item.productId),
                  onDecrement: () => notifier.decrementQuantity(item.productId),
                  onRemove: () => notifier.removeItem(item.productId),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Right Column: Order Summary (flex 2)
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: OrderSummaryCard(
                cart: state.cart,
                isCheckingOut: state.isCheckingOut,
                onCheckout: () => notifier.checkout(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
