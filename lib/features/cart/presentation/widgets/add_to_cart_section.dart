import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routing/app_router.dart';
import '../../../products/domain/entities/product.dart';

/// Interactive section embedded on the Product Details page providing a quantity
/// stepper, stock limits validation, cart-wide capacity feedback, and Add to Cart action button.
class AddToCartSection extends ConsumerStatefulWidget {
  final Product product;

  const AddToCartSection({super.key, required this.product});

  @override
  ConsumerState<AddToCartSection> createState() => _AddToCartSectionState();
}

class _AddToCartSectionState extends ConsumerState<AddToCartSection> {
  int _quantity = 1;

  void _increment(int effectiveQuantity, int maxAddable) {
    if (effectiveQuantity < maxAddable) {
      setState(() {
        _quantity = effectiveQuantity + 1;
      });
    }
  }

  void _decrement(int effectiveQuantity) {
    if (effectiveQuantity > 1) {
      setState(() {
        _quantity = effectiveQuantity - 1;
      });
    }
  }

  Future<void> _onAddToCart(int quantity) async {
    if (quantity <= 0) return;
    final notifier = ref.read(cartNotifierProvider.notifier);
    final success = await notifier.addItem(widget.product, quantity: quantity);

    if (!mounted) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (success) {
      setState(() {
        _quantity = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $quantity × "${widget.product.title}" to cart',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.ivorySurfaceVariant,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.ivoryBorder,
            ),
          ),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: isDark
                ? AppColors.darkForestGreen
                : AppColors.forestGreen,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              context.go(AppRoutes.cart);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cart = ref.watch(cartNotifierProvider).cart;
    final productStock = widget.product.stock;
    final inStock = widget.product.isInStock;
    final inCart = cart.findByProductId(widget.product.id)?.quantity ?? 0;
    final isCartFull = cart.isFull;
    final isStockLimitReached = inStock && inCart >= productStock;
    final maxAddable = cart.maxAddableForProduct(
      productStock,
      widget.product.id,
    );
    final canAdd = maxAddable > 0;
    final effectiveQuantity = canAdd ? _quantity.clamp(1, maxAddable) : 0;
    final remainingStockForProduct = (productStock - inCart).clamp(
      0,
      productStock,
    );
    final totalAmount = widget.product.effectivePrice * effectiveQuantity;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.ivorySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.ivoryBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      inStock
                          ? 'Available stock: $productStock units'
                          : 'Out of stock',
                      key: const Key('available_stock_text'),
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: !inStock
                            ? AppColors.error
                            : (widget.product.isLowStock
                                  ? (isDark
                                        ? AppColors.darkSaleOrange
                                        : AppColors.saleOrange)
                                  : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Stepper
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.ivorySurfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.ivoryBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, size: 18.0),
                      tooltip: 'Decrease quantity',
                      padding: const EdgeInsets.all(4.0),
                      constraints: const BoxConstraints(
                        minWidth: 40.0,
                        minHeight: 40.0,
                      ),
                      onPressed: canAdd && effectiveQuantity > 1
                          ? () => _decrement(effectiveQuantity)
                          : null,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 32.0),
                      alignment: Alignment.center,
                      child: Text(
                        '$effectiveQuantity',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18.0),
                      tooltip: 'Increase quantity',
                      padding: const EdgeInsets.all(4.0),
                      constraints: const BoxConstraints(
                        minWidth: 40.0,
                        minHeight: 40.0,
                      ),
                      onPressed: canAdd && effectiveQuantity < maxAddable
                          ? () => _increment(effectiveQuantity, maxAddable)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.gapSm,

          // Real API Stock & Capacity Info Row
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (inCart > 0) ...[
                Text(
                  '($inCart in cart)',
                  key: const Key('in_cart_quantity_text'),
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  '•',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
              Text(
                'Max additional: $maxAddable',
                key: const Key('max_additional_quantity_text'),
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: maxAddable == 0
                      ? (isDark
                            ? AppColors.darkSaleOrange
                            : AppColors.saleOrange)
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                ),
              ),
              Text(
                '•',
                style: TextStyle(
                  fontSize: 12.0,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                'Selected: $effectiveQuantity',
                key: const Key('selected_quantity_text'),
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Informative helper when stepper reaches upper bound
          if (canAdd && effectiveQuantity >= maxAddable) ...[
            const SizedBox(height: 4.0),
            Text(
              maxAddable < remainingStockForProduct
                  ? 'Cart capacity limit reached: you can add at most $maxAddable more units.'
                  : 'Stock limit reached: you can add at most $maxAddable more units.',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkSaleOrange : AppColors.saleOrange,
              ),
            ),
          ],

          // Distinct inline status banners for zero addable capacity
          if (!inStock) ...[
            AppSpacing.gapSm,
            Container(
              key: const Key('out_of_stock_inline_message'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.error.withValues(alpha: 0.15)
                    : AppColors.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.error, width: 1.0),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cancel_outlined,
                    size: 18.0,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'This product is currently out of stock.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isCartFull) ...[
            AppSpacing.gapSm,
            Container(
              key: const Key('cart_full_inline_message'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.saleOrange.withValues(alpha: 0.15)
                    : AppColors.saleOrangeContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkSaleOrange
                      : AppColors.saleOrange,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18.0,
                    color: isDark
                        ? AppColors.darkSaleOrange
                        : AppColors.saleOrange,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Your cart is full. Remove an item or reduce quantities to add more.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkSaleOrange
                            : AppColors.onSaleOrangeContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isStockLimitReached) ...[
            AppSpacing.gapSm,
            Container(
              key: const Key('stock_limit_inline_message'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.ivorySurfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.ivoryBorder,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18.0,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'You already have all $productStock available units in your cart.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          AppSpacing.gapMd,
          const Divider(height: 1.0),
          AppSpacing.gapMd,

          // Add to Cart Action Button
          ElevatedButton(
            onPressed: canAdd ? () => _onAddToCart(effectiveQuantity) : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48.0),
              backgroundColor: isDark
                  ? AppColors.darkForestGreen
                  : AppColors.forestGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.ivoryBorder,
              disabledForegroundColor: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    !inStock
                        ? Icons.remove_shopping_cart_outlined
                        : (isCartFull
                              ? Icons.shopping_bag_outlined
                              : (isStockLimitReached
                                    ? Icons.inventory_2_outlined
                                    : Icons.add_shopping_cart_rounded)),
                    size: 20.0,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    !inStock
                        ? 'Out of Stock'
                        : (isCartFull
                              ? 'Cart Full'
                              : (isStockLimitReached
                                    ? 'Stock Limit Reached'
                                    : 'Add to Cart  •  \$${totalAmount.toStringAsFixed(2)}')),
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
