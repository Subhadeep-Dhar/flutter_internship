import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/cart.dart';

/// Card widget displaying the financial totals for the active cart,
/// simulated checkout disclaimer, and the Place Order action button.
class OrderSummaryCard extends StatelessWidget {
  final Cart cart;
  final bool isCheckingOut;
  final VoidCallback? onCheckout;

  const OrderSummaryCard({
    super.key,
    required this.cart,
    required this.isCheckingOut,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          Text(
            'Order Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapMd,

          // Subtotal
          _SummaryRow(
            label: 'Subtotal (${cart.totalItems} items)',
            value: '\$${cart.subtotal.toStringAsFixed(2)}',
          ),

          // Total Discount / Savings
          if (cart.totalDiscount > 0) ...[
            AppSpacing.gapSm,
            _SummaryRow(
              label: 'Discounts Applied',
              value: '-\$${cart.totalDiscount.toStringAsFixed(2)}',
              valueColor: isDark
                  ? AppColors.darkSaleOrange
                  : AppColors.saleOrange,
            ),
          ],

          // Shipping
          AppSpacing.gapSm,
          _SummaryRow(
            label: 'Estimated Shipping',
            value: 'FREE',
            valueColor: isDark
                ? AppColors.darkForestGreen
                : AppColors.forestGreen,
          ),

          AppSpacing.gapMd,
          const Divider(height: 1.0),
          AppSpacing.gapMd,

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Grand Total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '\$${cart.grandTotal.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkForestGreen
                        : AppColors.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,

          // Simulated Order Notice Callout
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.ivorySurfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16.0,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Simulated Order: DummyJSON simulates order submission; no actual payment is collected.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.0,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapLg,

          // Checkout CTA Button
          ElevatedButton(
            onPressed: isCheckingOut || cart.isEmpty ? null : onCheckout,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50.0),
              backgroundColor: isDark
                  ? AppColors.darkForestGreen
                  : AppColors.forestGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: isCheckingOut
                ? const SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 18.0),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Place Order (Simulated)',
                          style: TextStyle(
                            fontSize: 16.0,
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
