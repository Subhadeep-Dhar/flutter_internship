import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/product.dart';

/// Renders the essential summary information for a product:
/// brand, category, title, ratings, pricing, stock status, and description.
class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category & Brand Badges
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkMutedSage.withValues(alpha: 0.2)
                    : AppColors.mutedSageContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Text(
                product.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isDark
                      ? AppColors.darkMutedSage
                      : AppColors.onMutedSageContainer,
                ),
              ),
            ),
            if (product.brand != null && product.brand!.trim().isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkForestGreen.withValues(alpha: 0.15)
                      : AppColors.forestGreenContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  product.brand!.trim(),
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: isDark
                        ? AppColors.darkForestGreen
                        : AppColors.forestGreenDark,
                  ),
                ),
              ),
            ],
          ],
        ),
        AppSpacing.gapSm,

        // Product Title
        Text(
          product.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.25,
          ),
        ),
        AppSpacing.gapSm,

        // Rating, Reviews & Stock Status Row
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            // Rating badge
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 20.0,
                  color: Color(0xFFE6A23C),
                ),
                const SizedBox(width: 4.0),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (product.hasReviews) ...[
                  const SizedBox(width: 4.0),
                  Text(
                    '(${product.reviewCount} ${product.reviewCount == 1 ? 'review' : 'reviews'})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),

            // Stock Availability Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: 3.0,
              ),
              decoration: BoxDecoration(
                color: !product.isInStock
                    ? (isDark
                          ? AppColors.darkErrorContainer.withValues(alpha: 0.35)
                          : AppColors.errorContainer)
                    : (product.isLowStock
                          ? (isDark
                                ? AppColors.darkSaleOrange.withValues(
                                    alpha: 0.2,
                                  )
                                : AppColors.saleOrangeContainer)
                          : (isDark
                                ? AppColors.darkForestGreen.withValues(
                                    alpha: 0.15,
                                  )
                                : AppColors.forestGreenContainer)),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    !product.isInStock
                        ? Icons.cancel_outlined
                        : (product.isLowStock
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline_rounded),
                    size: 14.0,
                    color: !product.isInStock
                        ? (isDark ? AppColors.darkError : AppColors.error)
                        : (product.isLowStock
                              ? (isDark
                                    ? AppColors.darkSaleOrange
                                    : AppColors.saleOrange)
                              : (isDark
                                    ? AppColors.darkForestGreen
                                    : AppColors.forestGreen)),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    product.stockStatusLabel,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      color: !product.isInStock
                          ? (isDark ? AppColors.darkError : AppColors.error)
                          : (product.isLowStock
                                ? (isDark
                                      ? AppColors.darkSaleOrange
                                      : AppColors.onSaleOrangeContainer)
                                : (isDark
                                      ? AppColors.darkForestGreen
                                      : AppColors.forestGreenDark)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.gapLg,

        // Price Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Effective Price
            Text(
              '\$${product.effectivePrice.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isDark
                    ? AppColors.darkForestGreen
                    : AppColors.forestGreen,
                letterSpacing: -0.5,
              ),
            ),

            if (product.hasDiscount) ...[
              const SizedBox(width: AppSpacing.sm),
              // Struck-through Original Price
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Discount pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.saleOrange,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  '-${product.discountPercentage!.round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.0,
                  ),
                ),
              ),
            ],
          ],
        ),
        AppSpacing.gapLg,

        // Description Header
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.gapXs,

        // Description Body
        Text(
          product.description.isNotEmpty
              ? product.description
              : 'No description provided for this product.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textSecondary,
            height: 1.5,
          ),
        ),

        // Product Tags
        if (product.tags.isNotEmpty) ...[
          AppSpacing.gapMd,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: product.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.ivorySurfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.ivoryBorder,
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 11.0,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.mutedSageDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
