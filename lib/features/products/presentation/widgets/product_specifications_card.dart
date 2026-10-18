import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/product.dart';

class _SpecItem {
  final String label;
  final String value;
  final IconData icon;

  const _SpecItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

/// Displays available specifications, logistics, warranty, and policy metadata.
/// Omits missing or empty values so blank labels are never rendered.
class ProductSpecificationsCard extends StatelessWidget {
  final Product product;

  const ProductSpecificationsCard({super.key, required this.product});

  List<_SpecItem> _extractAvailableSpecs() {
    final specs = <_SpecItem>[];

    if (product.sku != null && product.sku!.trim().isNotEmpty) {
      specs.add(
        _SpecItem(
          label: 'SKU',
          value: product.sku!.trim(),
          icon: Icons.tag_rounded,
        ),
      );
    }

    if (product.warrantyInformation != null &&
        product.warrantyInformation!.trim().isNotEmpty) {
      specs.add(
        _SpecItem(
          label: 'Warranty',
          value: product.warrantyInformation!.trim(),
          icon: Icons.verified_user_outlined,
        ),
      );
    }

    if (product.shippingInformation != null &&
        product.shippingInformation!.trim().isNotEmpty) {
      specs.add(
        _SpecItem(
          label: 'Shipping',
          value: product.shippingInformation!.trim(),
          icon: Icons.local_shipping_outlined,
        ),
      );
    }

    if (product.returnPolicy != null &&
        product.returnPolicy!.trim().isNotEmpty) {
      specs.add(
        _SpecItem(
          label: 'Return Policy',
          value: product.returnPolicy!.trim(),
          icon: Icons.assignment_return_outlined,
        ),
      );
    }

    final dimFormatted = product.dimensions?.formatted;
    if (dimFormatted != null && dimFormatted.isNotEmpty) {
      specs.add(
        _SpecItem(
          label: 'Dimensions',
          value: dimFormatted,
          icon: Icons.straighten_rounded,
        ),
      );
    }

    if (product.weight != null && product.weight! > 0) {
      specs.add(
        _SpecItem(
          label: 'Weight',
          value: '${product.weight}g',
          icon: Icons.scale_rounded,
        ),
      );
    }

    if (product.minimumOrderQuantity != null &&
        product.minimumOrderQuantity! > 0) {
      specs.add(
        _SpecItem(
          label: 'Min Order Qty',
          value: '${product.minimumOrderQuantity} units',
          icon: Icons.shopping_basket_outlined,
        ),
      );
    }

    if (product.meta?.barcode != null &&
        product.meta!.barcode!.trim().isNotEmpty) {
      specs.add(
        _SpecItem(
          label: 'Barcode',
          value: product.meta!.barcode!.trim(),
          icon: Icons.qr_code_2_rounded,
        ),
      );
    }

    return specs;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final specs = _extractAvailableSpecs();

    if (specs.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.ivorySurfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.ivoryBorder,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20.0,
                color: isDark
                    ? AppColors.darkForestGreen
                    : AppColors.forestGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Specifications & Policies',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          const Divider(height: 1.0),
          AppSpacing.gapMd,
          ...specs.map((spec) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    spec.icon,
                    size: 16.0,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.mutedSage,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 110.0,
                    child: Text(
                      spec.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      spec.value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
