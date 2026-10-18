import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/cart_item.dart';

/// Interactive card widget displaying an individual cart item, unit price,
/// quantity controls, stock limit alerts, and line total.
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.ivorySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.ivoryBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thumbnail Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Container(
              width: 80.0,
              height: 80.0,
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.ivorySurfaceVariant,
              child: item.thumbnail.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 32.0,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.mutedSage,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 32.0,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.mutedSage,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // 2. Info & Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Delete Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20.0),
                      tooltip: 'Remove ${item.title}',
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36.0,
                        minHeight: 36.0,
                      ),
                      onPressed: onRemove,
                    ),
                  ],
                ),
                AppSpacing.gapXs,

                // Unit Price & Discount
                Row(
                  children: [
                    Text(
                      '\$${item.effectiveUnitPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForestGreen
                            : AppColors.forestGreen,
                      ),
                    ),
                    if (item.discountPercentage != null &&
                        item.discountPercentage! > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 1.0,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSaleOrange.withValues(alpha: 0.2)
                              : AppColors.saleOrangeContainer,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXs,
                          ),
                        ),
                        child: Text(
                          '-${item.discountPercentage!.round()}%',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkSaleOrange
                                : AppColors.saleOrange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                AppSpacing.gapSm,

                // Quantity Controls & Line Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Stepper
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.ivorySurfaceVariant,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
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
                            icon: Icon(
                              item.quantity <= 1
                                  ? Icons.delete_outline_rounded
                                  : Icons.remove_rounded,
                              size: 16.0,
                            ),
                            tooltip: item.quantity <= 1
                                ? 'Remove item'
                                : 'Decrease quantity',
                            padding: const EdgeInsets.all(4.0),
                            constraints: const BoxConstraints(
                              minWidth: 36.0,
                              minHeight: 36.0,
                            ),
                            onPressed: onDecrement,
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 28.0),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 16.0),
                            tooltip: item.isAtStockLimit
                                ? 'Stock limit reached'
                                : 'Increase quantity',
                            padding: const EdgeInsets.all(4.0),
                            constraints: const BoxConstraints(
                              minWidth: 36.0,
                              minHeight: 36.0,
                            ),
                            onPressed: item.isAtStockLimit ? null : onIncrement,
                          ),
                        ],
                      ),
                    ),

                    // Line Total
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            fontSize: 11.0,
                          ),
                        ),
                        Text(
                          '\$${item.lineTotal.toStringAsFixed(2)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkForestGreen
                                : AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Stock limit warning pill
                if (item.isAtStockLimit) ...[
                  AppSpacing.gapXs,
                  Text(
                    'Max available stock reached (${item.stock})',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkSaleOrange
                          : AppColors.saleOrange,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
