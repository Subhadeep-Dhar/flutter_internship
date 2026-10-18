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
import '../../../../core/widgets/logout_confirmation_dialog.dart';
import '../../../../routing/app_router.dart';
import '../../../../routing/app_scaffold_shell.dart';
import '../controllers/product_list_state.dart';
import '../widgets/category_chips_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/product_error_banner.dart';
import '../widgets/product_grid_skeleton.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/product_sort_bottom_sheet.dart';
import 'product_detail_page.dart';
import '../../../cart/presentation/widgets/cart_badge_icon_button.dart';

/// Full-featured, responsive ShopSphere product catalogue screen supporting:
/// - Compact (< 600 dp): 2-column grid and bottom NavigationBar.
/// - Medium (600–1024 dp): 3-4 column grid and NavigationRail.
/// - Expanded (> 1024 dp): NavigationRail and master-detail side-by-side layout.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final ScrollController _scrollController;
  int? _selectedProductId;

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
    final cartCount = ref.watch(cartItemCountProvider);

    final width = MediaQuery.sizeOf(context).width;
    final screenType = Breakpoints.fromWidth(width);
    final isCompact = screenType == ScreenType.compact;
    final isMedium = screenType == ScreenType.medium;
    final isExpanded = screenType == ScreenType.expanded;
    final columnCount = Breakpoints.gridColumnCount(width);

    // Keep selected product valid for expanded master-detail layout
    if (isExpanded) {
      if (productState.products.isEmpty) {
        _selectedProductId = null;
      } else if (_selectedProductId == null ||
          !productState.products.any((p) => p.id == _selectedProductId)) {
        _selectedProductId = productState.products.first.id;
      }
    }

    final hasShell =
        context.findAncestorWidgetOfExactType<AppScaffoldShell>() != null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
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
            Flexible(
              child: Text(
                'ShopSphere',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Shopping Cart Button with Real-time Count Badge
          const CartBadgeIconButton(),

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
            onPressed: () => context.go(AppRoutes.profile),
          ),

          // Logout Action with confirmation modal
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              LogoutConfirmationDialog.show(context);
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      bottomNavigationBar: (isCompact && !hasShell)
          ? _buildBottomNavigationBar(cartCount)
          : null,
      body: SafeArea(
        child: isCompact
            ? _buildCatalogueColumn(
                context: context,
                productState: productState,
                productNotifier: productNotifier,
                isDark: isDark,
                theme: theme,
                columnCount: columnCount,
                isExpanded: false,
              )
            : isMedium
            ? (hasShell
                  ? _buildCatalogueColumn(
                      context: context,
                      productState: productState,
                      productNotifier: productNotifier,
                      isDark: isDark,
                      theme: theme,
                      columnCount: columnCount,
                      isExpanded: false,
                    )
                  : Row(
                      children: [
                        _buildNavigationRail(cartCount),
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(
                          child: _buildCatalogueColumn(
                            context: context,
                            productState: productState,
                            productNotifier: productNotifier,
                            isDark: isDark,
                            theme: theme,
                            columnCount: columnCount,
                            isExpanded: false,
                          ),
                        ),
                      ],
                    ))
            : (hasShell
                  ? Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildCatalogueColumn(
                            context: context,
                            productState: productState,
                            productNotifier: productNotifier,
                            isDark: isDark,
                            theme: theme,
                            columnCount: 2,
                            isExpanded: true,
                          ),
                        ),
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(flex: 6, child: _buildDetailPane(isDark)),
                      ],
                    )
                  : Row(
                      children: [
                        _buildNavigationRail(cartCount),
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(
                          flex: 5,
                          child: _buildCatalogueColumn(
                            context: context,
                            productState: productState,
                            productNotifier: productNotifier,
                            isDark: isDark,
                            theme: theme,
                            columnCount: 2,
                            isExpanded: true,
                          ),
                        ),
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(flex: 6, child: _buildDetailPane(isDark)),
                      ],
                    )),
      ),
    );
  }

  Widget _buildBottomNavigationBar(int cartCount) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 1) {
          context.go(AppRoutes.cart);
        } else if (index == 2) {
          context.go(AppRoutes.profile);
        } else if (index == 0) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      },
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront_rounded),
          label: 'Catalogue',
        ),
        NavigationDestination(
          icon: cartCount > 0
              ? Badge.count(
                  count: cartCount,
                  child: const Icon(Icons.shopping_bag_outlined),
                )
              : const Icon(Icons.shopping_bag_outlined),
          selectedIcon: cartCount > 0
              ? Badge.count(
                  count: cartCount,
                  child: const Icon(Icons.shopping_bag_rounded),
                )
              : const Icon(Icons.shopping_bag_rounded),
          label: 'Cart',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildNavigationRail(int cartCount) {
    return NavigationRail(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 1) {
          context.go(AppRoutes.cart);
        } else if (index == 2) {
          context.go(AppRoutes.profile);
        } else if (index == 0) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      },
      labelType: NavigationRailLabelType.all,
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront_rounded),
          label: Text('Catalogue'),
        ),
        NavigationRailDestination(
          icon: cartCount > 0
              ? Badge.count(
                  count: cartCount,
                  child: const Icon(Icons.shopping_bag_outlined),
                )
              : const Icon(Icons.shopping_bag_outlined),
          selectedIcon: cartCount > 0
              ? Badge.count(
                  count: cartCount,
                  child: const Icon(Icons.shopping_bag_rounded),
                )
              : const Icon(Icons.shopping_bag_rounded),
          label: const Text('Cart'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: Text('Profile'),
        ),
      ],
    );
  }

  Widget _buildDetailPane(bool isDark) {
    if (_selectedProductId != null) {
      return ProductDetailPage(
        key: ValueKey(_selectedProductId),
        productId: _selectedProductId!,
        isEmbedded: true,
      );
    }
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.ivoryBackground,
      child: const Center(
        child: AppEmptyView(
          icon: Icons.touch_app_outlined,
          title: 'Select a Product',
          message:
              'Choose any product from the catalogue on the left to preview its full details, specifications, and customer reviews.',
        ),
      ),
    );
  }

  Widget _buildCatalogueColumn({
    required BuildContext context,
    required ProductListState productState,
    required dynamic productNotifier,
    required bool isDark,
    required ThemeData theme,
    required int columnCount,
    required bool isExpanded,
  }) {
    return Column(
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
            isRetrying: productState.isLoadingMore || productState.isRefreshing,
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
            isExpanded: isExpanded,
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogueContent({
    required BuildContext context,
    required ProductListState state,
    required dynamic notifier,
    required int columnCount,
    required bool isExpanded,
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
    final width = MediaQuery.sizeOf(context).width;
    final screenType = Breakpoints.fromWidth(width);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double childAspectRatio;
    if (isExpanded) {
      childAspectRatio = 0.80;
    } else if (screenType == ScreenType.medium) {
      childAspectRatio = 0.78;
    } else {
      childAspectRatio = textScale > 1.1 ? 0.67 : (width < 350 ? 1.15 : 0.78);
    }

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
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = state.products[index];
                return ProductCard(
                  product: product,
                  isSelected: isExpanded && product.id == _selectedProductId,
                  onTap: () {
                    if (isExpanded) {
                      setState(() {
                        _selectedProductId = product.id;
                      });
                    } else {
                      context.push('/product/${product.id}');
                    }
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
