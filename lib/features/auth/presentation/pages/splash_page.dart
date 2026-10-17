import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Foundation splash screen for ShopSphere.
///
/// Serves as the initial entry screen displaying the brand identity
/// while the authentication state and local caches are verified.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.ivoryBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Brand Icon Container
              Container(
                width: 96.0,
                height: 96.0,
                decoration: BoxDecoration(
                  color: AppColors.forestGreen,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withValues(alpha: 0.2),
                      blurRadius: 20.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 48.0,
                  color: Colors.white,
                ),
              ),
              AppSpacing.gapXxl,
              // Brand Title
              Text(
                'ShopSphere',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: AppColors.forestGreenDark,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              AppSpacing.gapSm,
              // Brand Tagline
              Text(
                'Curated Shopping Experience',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedSage,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Subtle Loading Indicator
              const AppLoadingIndicator(size: 28.0),
              AppSpacing.gapXl,
              Text(
                'v1.0.0 • Clean Architecture',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              AppSpacing.gapLg,
            ],
          ),
        ),
      ),
    );
  }
}
