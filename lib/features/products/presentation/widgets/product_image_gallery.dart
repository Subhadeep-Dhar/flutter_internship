import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Interactive, responsive product image gallery with horizontally swipeable
/// PageView, animated dot indicators, clickable thumbnails, and robust fallbacks.
class ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final String thumbnail;
  final String productTitle;

  const ProductImageGallery({
    super.key,
    required this.images,
    required this.thumbnail,
    required this.productTitle,
  });

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late final PageController _pageController;
  int _currentPage = 0;

  List<String> get _resolvedImages {
    final validImages = widget.images
        .where((img) => img.trim().isNotEmpty)
        .toList();
    if (validImages.isNotEmpty) return validImages;
    if (widget.thumbnail.trim().isNotEmpty) return [widget.thumbnail.trim()];
    return const [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onThumbnailTapped(int index) {
    if (index == _currentPage) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final images = _resolvedImages;

    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 1.05,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.ivorySurfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.ivoryBorder,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 56.0,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.mutedSage,
              ),
              AppSpacing.gapSm,
              Text(
                'No product images available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Image Display inside AspectRatio
        AspectRatio(
          aspectRatio: 1.05,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.ivorySurfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.ivoryBorder,
              ),
            ),
            child: Semantics(
              label:
                  '${widget.productTitle} image ${_currentPage + 1} of ${images.length}',
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.forestGreen,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image_rounded,
                              size: 48.0,
                              color: AppColors.mutedSage,
                            ),
                            AppSpacing.gapXs,
                            Text(
                              'Image unavailable',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedSage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Multiple images: Dots indicator + Thumbnails strip
        if (images.length > 1) ...[
          AppSpacing.gapSm,

          // Smooth Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isSelected = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                width: isSelected ? 20.0 : 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? AppColors.darkForestGreen
                            : AppColors.forestGreen)
                      : (isDark
                            ? AppColors.darkBorder
                            : AppColors.mutedSage.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              );
            }),
          ),
          AppSpacing.gapSm,

          // Thumbnails Strip
          SizedBox(
            height: 60.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              itemCount: images.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final isSelected = index == _currentPage;
                final imageUrl = images[index];

                return Semantics(
                  button: true,
                  label: 'Switch to image ${index + 1} of ${images.length}',
                  child: InkWell(
                    onTap: () => _onThumbnailTapped(index),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.ivorySurfaceVariant,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? (isDark
                                    ? AppColors.darkForestGreen
                                    : AppColors.forestGreen)
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.ivoryBorder),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXs,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image_rounded,
                            size: 20.0,
                            color: AppColors.mutedSage,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
