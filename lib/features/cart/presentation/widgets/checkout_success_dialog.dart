import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/checkout_result.dart';

/// Modal dialog presented when a simulated checkout succeeds.
class CheckoutSuccessDialog extends StatelessWidget {
  final CheckoutResult result;
  final VoidCallback onDismiss;

  const CheckoutSuccessDialog({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.ivorySurface,
      contentPadding: const EdgeInsets.all(AppSpacing.xl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Green Success Icon
          Container(
            width: 64.0,
            height: 64.0,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkForestGreen.withValues(alpha: 0.2)
                  : AppColors.forestGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 40.0,
              color: isDark ? AppColors.darkForestGreen : AppColors.forestGreen,
            ),
          ),
          AppSpacing.gapMd,

          Text(
            'Order Placed!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapXs,
          Text(
            'Simulated order successfully received',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapLg,

          // Order Details Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.ivorySurfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.ivoryBorder,
              ),
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: 'Reference ID',
                  value: '#ORD-${result.id}',
                  isBold: true,
                ),
                const SizedBox(height: 6.0),
                _DetailRow(
                  label: 'Total Items',
                  value: '${result.totalQuantity} items',
                ),
                const SizedBox(height: 6.0),
                _DetailRow(
                  label: 'Amount Paid',
                  value: '\$${result.discountedTotal.toStringAsFixed(2)}',
                  isBold: true,
                  color: isDark
                      ? AppColors.darkForestGreen
                      : AppColors.forestGreen,
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,

          // Honest Disclaimer
          Text(
            'DummyJSON simulates this order; no real payment has been processed and your cart has been cleared.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.0,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapLg,

          // Continue Shopping Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48.0),
                backgroundColor: isDark
                    ? AppColors.darkForestGreen
                    : AppColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
