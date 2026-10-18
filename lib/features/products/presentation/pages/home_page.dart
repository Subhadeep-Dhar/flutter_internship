import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../routing/app_router.dart';
import '../controllers/product_list_state.dart';
import '../widgets/category_chips_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_error_banner.dart';
import '../widgets/product_grid_skeleton.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/product_sort_bottom_sheet.dart';

/// Full-featured, responsive ShopSphere product catalogue screen.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(productListNotifierProvider);
      if (state.isInitial || (state.isError && state.products.isEmpty)) {
        ref.read(productListNotifierProvider.notifier).loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger next page when scrolling within 300dp of bottom
    if (currentScroll >= maxScroll - 300) {
      ref.read(productListNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final user = authState.userOrNull;

    final productState = ref.watch(productListNotifierProvider);
    final productNotifier = ref.read(productListNotifierProvider.notifier);

    final width = MediaQuery.sizeOf(context).width;
    final columnCount = Breakpoints.gridColumnCount(width);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkForestGreen.withValues(alpha: 0.2)
                    : AppColors.forestGreenContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_mall_rounded,
                color: isDark
                    ? AppColors.darkForestGreen
                    : AppColors.forestGreenDark,
                size: 20.0,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'ShopSphere',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Profile Button with User Avatar
          IconButton(
            tooltip: 'Profile',
            icon: CircleAvatar(
              radius: 16.0,
              backgroundColor: isDark
                  ? AppColors.darkForestGreen.withValues(alpha: 0.2)
                  : AppColors.forestGreenContainer,
              child: user?.image != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user!.image!,
                        width: 32.0,
                        height: 32.0,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Text(
                          user.initials,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkForestGreen
                                : AppColors.forestGreenDark,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      user?.initials ?? '?',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkForestGreen
                            : AppColors.forestGreenDark,
                      ),
                    ),
            ),
            onPressed: () => context.push(AppRoutes.profile),
          ),

          // Logout Action
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppSpacing.gapSm,

            // Search Bar & Sort Action
            ProductSearchBar(
              initialQuery: productState.searchQuery,
              activeSort: productState.sortOption,
              onChanged: productNotifier.onSearchInput,
              onSubmitted: productNotifier.submitSearch,
              onClear: productNotifier.clearFilters,
              onSortTap: () {
                ProductSortBottomSheet.show(
                  context: context,
                  selectedOption: productState.sortOption,
                  onSelect: productNotifier.setSortOption,
                  onReset: () =>
                      productNotifier.setSortOption(productState.sortOption),
                );
              },
            ),
            AppSpacing.gapSm,

            // Horizontal Category Chips
            if (productState.categories.isNotEmpty) ...[
              CategoryChipsBar(
                categories: productState.categories,
                selectedCategory: productState.selectedCategory,
                onSelectCategory: productNotifier.selectCategory,
              ),
              AppSpacing.gapSm,
            ],

            // Active Filters Banner (shown when search, category, or sort is applied)
            if (productState.hasActiveFilters)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      size: 16.0,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.mutedSage,
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        _buildFilterSummary(productState),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: productNotifier.clearFilters,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      child: const Text(
                        'Clear all',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ),

            // Top-Level Error Banner (visible without scrolling for refresh / pagination failures)
            if (productState.bannerErrorMessage != null) ...[
              ProductErrorBanner(
                message: productState.bannerErrorMessage!,
                onRetry: productNotifier.retry,
                onDismiss: productNotifier.dismissBannerError,
                isRetrying:
                    productState.isLoadingMore || productState.isRefreshing,
              ),
              AppSpacing.gapSm,
            ],

            // Main Catalogue Content Area
            Expanded(
              child: _buildCatalogueContent(
                context: context,
                state: productState,
                notifier: productNotifier,
                columnCount: columnCount,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogueContent({
    required BuildContext context,
    required ProductListState state,
    required dynamic notifier,
    required int columnCount,
  }) {
    // 1. Initial Loading State: Animated Skeletons
    if ((state.isLoading || state.isInitial) && state.products.isEmpty) {
      return const ProductGridSkeleton();
    }

    // 2. Initial Error State
    if (state.isError && state.products.isEmpty) {
      return AppErrorView(
        message:
            state.errorMessage ??
            'Unable to connect to the catalogue. Please check your internet connection and try again.',
        retryLabel: 'Retry',
        onRetry: () => notifier.retry(),
      );
    }

    // 3. Empty Search / Filter State
    if (state.isEmpty || (state.isLoaded && state.products.isEmpty)) {
      return AppEmptyView(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message: state.searchQuery.isNotEmpty
            ? 'We couldn\'t find any items matching "${state.searchQuery}". Try a different search term or reset filters.'
            : 'No products are currently available in this category.',
        actionLabel: 'Reset Catalogue',
        onAction: () => notifier.clearFilters(),
      );
    }

    // 4. Products Grid with Pull-to-Refresh & Infinite Scroll
    return RefreshIndicator(
      color: AppColors.forestGreen,
      onRefresh: () => notifier.refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Responsive Product Grid
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                childAspectRatio: 0.68,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = state.products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.title} selected'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              }, childCount: state.products.length),
            ),
          ),

          // Pagination Footer: Loading More Spinner or Retry Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.xxl,
              ),
              child: _buildPaginationFooter(
                state: state,
                onRetryPagination: () => notifier.retry(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter({
    required ProductListState state,
    required VoidCallback onRetryPagination,
  }) {
    if (state.isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(AppColors.forestGreen),
            ),
          ),
        ),
      );
    }

    if (state.paginationErrorMessage != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 20.0,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                state.paginationErrorMessage!,
                style: const TextStyle(
                  color: AppColors.onErrorContainer,
                  fontSize: 12.0,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetryPagination,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!state.hasMore && state.products.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Showing all ${state.total} products',
            style: const TextStyle(
              fontSize: 12.0,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _buildFilterSummary(ProductListState state) {
    final parts = <String>[];
    if (state.searchQuery.isNotEmpty) {
      parts.add('Query: "${state.searchQuery}"');
    }
    if (state.selectedCategory != null && state.selectedCategory != 'all') {
      parts.add('Category: ${state.selectedCategory}');
    }
    if (!state.sortOption.isNone) {
      parts.add('Sort: ${state.sortOption.label}');
    }
    return parts.join(' • ');
  }
}
