import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable empty state view for empty search results, empty cart, or blank lists.
class AppEmptyView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AppEmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.ivorySurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.0,
                color: isDark ? AppColors.darkMutedSage : AppColors.mutedSage,
              ),
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
            if (onAction != null && actionLabel != null) ...[
              AppSpacing.gapXxl,
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? AppColors.darkForestGreen
                      : AppColors.forestGreen,
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkForestGreen
                        : AppColors.forestGreen,
                  ),
                  minimumSize: const Size(140.0, AppSpacing.minTapTarget),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
