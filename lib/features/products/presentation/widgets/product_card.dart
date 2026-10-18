import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/product.dart';

/// Polished, responsive product catalogue card.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.ivorySurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.ivoryBorder;

    return Semantics(
      label:
          '${product.title}, price \$${product.effectivePrice.toStringAsFixed(2)}, rated ${product.rating} stars, ${product.stockStatusLabel}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Thumbnail with Discount Badge
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSpacing.radiusMd - 1),
                        ),
                        child: Container(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.ivorySurfaceVariant,
                          child: product.thumbnail.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: product.thumbnail,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor: AlwaysStoppedAnimation(
                                          isDark
                                              ? AppColors.darkMutedSage
                                              : AppColors.mutedSage,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 32.0,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 32.0,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textTertiary,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // Discount Badge
                    if (product.discountPercentage != null &&
                        product.discountPercentage! > 0)
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.saleOrange,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXs,
                            ),
                          ),
                          child: Text(
                            '-${product.discountPercentage!.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),

                    // Stock Pill for Low / Out of Stock
                    if (!product.isInStock || product.isLowStock)
                      Positioned(
                        bottom: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: product.isInStock
                                ? AppColors.saleOrangeContainer
                                : AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXs,
                            ),
                          ),
                          child: Text(
                            product.stockStatusLabel,
                            style: TextStyle(
                              color: product.isInStock
                                  ? AppColors.onSaleOrangeContainer
                                  : AppColors.error,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Product Details
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Text(
                        product.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isDark
                              ? AppColors.darkMutedSage
                              : AppColors.mutedSage,
                        ),
                      ),
                      const SizedBox(height: 2.0),

                      // Title
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      AppSpacing.gapSm,

                      // Rating Row
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16.0,
                            color: Color(0xFFE6A23C),
                          ),
                          const SizedBox(width: 3.0),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          if (product.isInStock && !product.isLowStock)
                            Text(
                              '• In stock',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkForestGreen
                                    : AppColors.forestGreen,
                                fontWeight: FontWeight.w500,
                                fontSize: 11.0,
                              ),
                            ),
                        ],
                      ),
                      AppSpacing.gapSm,

                      // Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${product.effectivePrice.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkForestGreen
                                  : AppColors.forestGreen,
                            ),
                          ),
                          if (product.discountPercentage != null &&
                              product.discountPercentage! > 0) ...[
                            const SizedBox(width: 6.0),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
