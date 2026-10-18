import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routing/app_router.dart';
import '../../../products/domain/entities/product.dart';

/// Interactive section embedded on the Product Details page providing a quantity
/// stepper, stock limits validation, and Add to Cart action button.
class AddToCartSection extends ConsumerStatefulWidget {
  final Product product;

  const AddToCartSection({super.key, required this.product});

  @override
  ConsumerState<AddToCartSection> createState() => _AddToCartSectionState();
}

class _AddToCartSectionState extends ConsumerState<AddToCartSection> {
  int _quantity = 1;

  int get _maxStock => widget.product.stock > 0 ? widget.product.stock : 99;

  void _increment() {
    if (_quantity < _maxStock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  Future<void> _onAddToCart() async {
    final notifier = ref.read(cartNotifierProvider.notifier);
    final success = await notifier.addItem(widget.product, quantity: _quantity);

    if (!mounted) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $_quantity × "${widget.product.title}" to cart',
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
            onPressed: () => context.push(AppRoutes.cart),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inStock = widget.product.isInStock;
    final totalAmount = widget.product.effectivePrice * _quantity;

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
            children: [
              Text(
                'Quantity',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
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
                      onPressed: inStock && _quantity > 1 ? _decrement : null,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 32.0),
                      alignment: Alignment.center,
                      child: Text(
                        '$_quantity',
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
                      onPressed: inStock && _quantity < _maxStock
                          ? _increment
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (inStock && widget.product.isLowStock) ...[
            AppSpacing.gapXs,
            Text(
              'Only ${widget.product.stock} units left in stock',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkSaleOrange : AppColors.saleOrange,
              ),
            ),
          ],

          AppSpacing.gapMd,
          const Divider(height: 1.0),
          AppSpacing.gapMd,

          // Add to Cart Action Button
          ElevatedButton(
            onPressed: inStock ? _onAddToCart : null,
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
                    inStock
                        ? Icons.add_shopping_cart_rounded
                        : Icons.remove_shopping_cart_outlined,
                    size: 20.0,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    inStock
                        ? 'Add to Cart  •  \$${totalAmount.toStringAsFixed(2)}'
                        : 'Out of Stock',
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
