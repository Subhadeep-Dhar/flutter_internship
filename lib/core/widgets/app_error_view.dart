import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Standard, accessible error view with a retry action for network or server failures.
class AppErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  const AppErrorView({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final errorColor = isDark ? const Color(0xFFFFB4AB) : AppColors.error;
    final errorBgColor = isDark
        ? const Color(0xFF93000A).withValues(alpha: 0.35)
        : AppColors.errorContainer;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: errorBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48.0, color: errorColor),
            ),
            AppSpacing.gapLg,
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            AppSpacing.gapSm,
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : const Color(0xFF2E3831),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              AppSpacing.gapXxl,
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkForestGreen
                      : AppColors.forestGreen,
                  foregroundColor: isDark
                      ? AppColors.darkBackground
                      : Colors.white,
                  minimumSize: const Size(140.0, AppSpacing.minTapTarget),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
