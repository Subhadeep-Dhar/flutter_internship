import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// A persistent, accessible error banner displayed above the catalogue grid
/// when an operation fails while products are already displayed (such as a
/// failed pull-to-refresh or a failed pagination attempt).
class ProductErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onDismiss;
  final bool isRetrying;

  const ProductErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
    this.onDismiss,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;
    final containerColor = isDark
        ? AppColors.darkErrorContainer.withValues(alpha: 0.3)
        : AppColors.errorContainer;
    final borderColor = isDark
        ? AppColors.darkError.withValues(alpha: 0.4)
        : AppColors.error.withValues(alpha: 0.3);
    final textColor = isDark
        ? AppColors.darkOnErrorContainer
        : AppColors.onErrorContainer;

    return Semantics(
      liveRegion: true,
      label: 'Error notification: $message',
      child: Container(
        key: const ValueKey('product_error_banner'),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: errorColor, size: 20.0),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            if (isRetrying)
              SizedBox(
                width: 18.0,
                height: 18.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation(errorColor),
                ),
              )
            else
              TextButton.icon(
                key: const ValueKey('banner_retry_button'),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16.0),
                label: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: errorColor,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4.0,
                  ),
                ),
              ),
            if (onDismiss != null)
              IconButton(
                key: const ValueKey('banner_dismiss_button'),
                icon: const Icon(Icons.close_rounded, size: 18.0),
                tooltip: 'Dismiss error',
                color: textColor,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24.0,
                  minHeight: 24.0,
                ),
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}
