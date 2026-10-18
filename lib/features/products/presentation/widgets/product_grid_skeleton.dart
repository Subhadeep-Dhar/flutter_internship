import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/breakpoints.dart';

/// Loading skeleton grid shown while initial catalogue data is in-flight.
class ProductGridSkeleton extends StatefulWidget {
  final int itemCount;

  const ProductGridSkeleton({super.key, this.itemCount = 6});

  @override
  State<ProductGridSkeleton> createState() => _ProductGridSkeletonState();
}

class _ProductGridSkeletonState extends State<ProductGridSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columnCount = Breakpoints.gridColumnCount(width);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.ivorySurfaceVariant;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.ivorySurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.ivoryBorder;

    final screenType = Breakpoints.fromWidth(width);
    final double childAspectRatio;
    if (width >= Breakpoints.expandedMinWidth) {
      childAspectRatio = 0.80;
    } else if (screenType == ScreenType.medium) {
      childAspectRatio = 0.78;
    } else {
      childAspectRatio = width < 350 ? 1.15 : 0.78;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Placeholder
                  AspectRatio(
                    aspectRatio: 1.45,
                    child: Container(
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: _animation.value),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSpacing.radiusMd - 1),
                        ),
                      ),
                    ),
                  ),

                  // Text Placeholders
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      AppSpacing.xs + 2,
                      AppSpacing.sm,
                      AppSpacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Placeholder
                        Container(
                          width: 50.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: baseColor.withValues(
                              alpha: _animation.value,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXs,
                            ),
                          ),
                        ),
                        AppSpacing.gapSm,

                        // Title line 1
                        Container(
                          width: double.infinity,
                          height: 14.0,
                          decoration: BoxDecoration(
                            color: baseColor.withValues(
                              alpha: _animation.value,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXs,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6.0),

                        // Title line 2
                        Container(
                          width: 80.0,
                          height: 14.0,
                          decoration: BoxDecoration(
                            color: baseColor.withValues(
                              alpha: _animation.value,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXs,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6.0),

                        // Rating line
                        Container(
                          width: 48.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            color: baseColor.withValues(
                              alpha: _animation.value,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXs,
                            ),
                          ),
                        ),
                        AppSpacing.gapSm,

                        // Price
                        Container(
                          width: 60.0,
                          height: 18.0,
                          decoration: BoxDecoration(
                            color: baseColor.withValues(
                              alpha: _animation.value,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXs,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
