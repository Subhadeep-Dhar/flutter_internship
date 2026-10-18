import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_reviews_list.dart';
import '../widgets/product_specifications_card.dart';
import '../../../cart/presentation/widgets/add_to_cart_section.dart';
import '../../../cart/presentation/widgets/cart_badge_icon_button.dart';

/// Full-featured, responsive product detail screen displaying high-resolution
/// images, summary, specs, warranty, policies, and customer reviews.
class ProductDetailPage extends ConsumerWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(productDetailNotifierProvider(productId));

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.ivoryBackground,
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: const [CartBadgeIconButton()],
      ),
      body: SafeArea(
        child: switch (state.status) {
          _ when state.isInvalidId => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppEmptyView(
                icon: Icons.error_outline_rounded,
                title: 'Invalid Product',
                message:
                    state.errorMessage ??
                    'The requested product identifier is invalid.',
                actionLabel: 'Back to Catalogue',
                onAction: () => context.go('/home'),
              ),
            ),
          ),
          _ when state.isLoading || state.isInitial => const Center(
            child: AppLoadingIndicator(
              size: 32.0,
              message: 'Loading product details...',
            ),
          ),
          _ when state.isError => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppErrorView(
                title: 'Unable to Load Product',
                message:
                    state.errorMessage ??
                    'Could not retrieve product information. Please verify your connection and try again.',
                retryLabel: 'Retry',
                onRetry: () => ref
                    .read(productDetailNotifierProvider(productId).notifier)
                    .retry(),
              ),
            ),
          ),
          _ when state.isLoaded && state.product != null => LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isWide = width >= Breakpoints.mediumMinWidth;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200.0),
                  child: isWide
                      ? _buildWideLayout(context, state.product!)
                      : _buildCompactLayout(context, state.product!),
                ),
              );
            },
          ),
          _ => Center(
            child: AppEmptyView(
              icon: Icons.search_off_rounded,
              title: 'Product Not Found',
              message: 'The requested product is not available.',
              actionLabel: 'Back to Catalogue',
              onAction: () => context.go('/home'),
            ),
          ),
        },
      ),
    );
  }

  /// Compact vertical layout for mobile screens (< 600 dp).
  Widget _buildCompactLayout(BuildContext context, Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageGallery(
            images: product.images,
            thumbnail: product.thumbnail,
            productTitle: product.title,
          ),
          AppSpacing.gapXl,
          ProductInfoSection(product: product),
          AppSpacing.gapLg,
          AddToCartSection(product: product),
          AppSpacing.gapXl,
          ProductSpecificationsCard(product: product),
          AppSpacing.gapXl,
          ProductReviewsList(reviews: product.reviews),
          AppSpacing.gapXxl,
        ],
      ),
    );
  }

  /// Side-by-side master/detail layout for tablets and desktop (>= 600 dp).
  Widget _buildWideLayout(BuildContext context, Product product) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Image Gallery (flex: 5)
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: ProductImageGallery(
                images: product.images,
                thumbnail: product.thumbnail,
                productTitle: product.title,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),

          // Right: Information, Specs, and Reviews (flex: 6)
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfoSection(product: product),
                  AppSpacing.gapLg,
                  AddToCartSection(product: product),
                  AppSpacing.gapXl,
                  ProductSpecificationsCard(product: product),
                  AppSpacing.gapXl,
                  ProductReviewsList(reviews: product.reviews),
                  AppSpacing.gapXxl,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
