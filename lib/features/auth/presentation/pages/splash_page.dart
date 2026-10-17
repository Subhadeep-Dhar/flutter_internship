import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../controllers/auth_state.dart';

/// Splash screen that validates session credentials on launch and routes to Home or Login.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.ivoryBackground,
      body: SafeArea(
        child: switch (authState) {
          AuthSessionCheckFailed(:final failure) => Center(
            child: SingleChildScrollView(
              child: AppErrorView(
                title: 'Connection Issue',
                message: failure.message,
                retryLabel: 'Retry Session Check',
                onRetry: () {
                  ref.read(authNotifierProvider.notifier).checkSession();
                },
              ),
            ),
          ),
          _ => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Brand Logo Container
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
                Text(
                  'ShopSphere',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: AppColors.forestGreenDark,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                AppSpacing.gapSm,
                Text(
                  'Curated Shopping Experience',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedSage,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const AppLoadingIndicator(
                  size: 28.0,
                  message: 'Verifying session...',
                ),
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
        },
      ),
    );
  }
}
