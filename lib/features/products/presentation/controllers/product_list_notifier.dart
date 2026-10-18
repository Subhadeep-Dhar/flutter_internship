import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/debouncer.dart';
import '../../domain/entities/paginated_products.dart';
import '../../domain/entities/product_sort_option.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_by_category_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import 'product_list_state.dart';

/// Riverpod 3 Notifier managing product catalogue retrieval, pagination,
/// debounced search, category filtering, and sorting.
class ProductListNotifier extends Notifier<ProductListState> {
  final GetProductsUseCase? getProductsUseCase;
  final GetCategoriesUseCase? getCategoriesUseCase;
  final SearchProductsUseCase? searchProductsUseCase;
  final GetProductsByCategoryUseCase? getProductsByCategoryUseCase;

  late final Debouncer _searchDebouncer;
  int _activeRequestId = 0;

  ProductListNotifier({
    this.getProductsUseCase,
    this.getCategoriesUseCase,
    this.searchProductsUseCase,
    this.getProductsByCategoryUseCase,
    Debouncer? debouncer,
  }) {
    _searchDebouncer =
        debouncer ?? Debouncer(delay: const Duration(milliseconds: 400));
  }

  GetProductsUseCase get _productsUseCase =>
      getProductsUseCase ?? ref.read(getProductsUseCaseProvider);
  GetCategoriesUseCase get _categoriesUseCase =>
      getCategoriesUseCase ?? ref.read(getCategoriesUseCaseProvider);
  SearchProductsUseCase get _searchUseCase =>
      searchProductsUseCase ?? ref.read(searchProductsUseCaseProvider);
  GetProductsByCategoryUseCase get _categoryProductsUseCase =>
      getProductsByCategoryUseCase ??
      ref.read(getProductsByCategoryUseCaseProvider);

  @override
  ProductListState build() {
    ref.onDispose(() {
      _searchDebouncer.dispose();
    });

    return ProductListState.initial();
  }

  /// Initial load: retrieves both product categories and the first page of products.
  Future<void> loadInitial() async {
    state = state.copyWith(
      status: ProductListStatus.loading,
      errorMessage: () => null,
      paginationErrorMessage: () => null,
    );

    final requestId = ++_activeRequestId;

    // Fetch categories in parallel
    unawaited(_loadCategories());

    final result = await _fetchPage(
      skip: 0,
      query: state.searchQuery,
      category: state.selectedCategory,
      sort: state.sortOption,
    );

    if (requestId != _activeRequestId) return; // Stale request protection

    result.when(
      success: (paginated) {
        state = state.copyWith(
          status: paginated.products.isEmpty
              ? ProductListStatus.empty
              : ProductListStatus.loaded,
          products: paginated.products,
          skip: paginated.skip,
          limit: paginated.limit,
          total: paginated.total,
          hasMore: paginated.hasMore,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        state = state.copyWith(
          status: ProductListStatus.error,
          errorMessage: () => failure.message,
        );
      },
    );
  }

  /// Fetches available categories from the server.
  Future<void> _loadCategories() async {
    final result = await _categoriesUseCase();
    result.when(
      success: (categories) {
        state = state.copyWith(categories: categories);
      },
      error: (_) {
        // Silently preserve existing categories or fallback to empty
      },
    );
  }

  /// Refreshes the active product catalogue while preserving current filters.
  Future<void> refresh() async {
    final requestId = ++_activeRequestId;

    state = state.copyWith(
      isRefreshing: true,
      paginationErrorMessage: () => null,
    );

    // Refresh categories in background
    unawaited(_loadCategories());

    final result = await _fetchPage(
      skip: 0,
      query: state.searchQuery,
      category: state.selectedCategory,
      sort: state.sortOption,
    );

    if (requestId != _activeRequestId) return;

    result.when(
      success: (paginated) {
        state = state.copyWith(
          status: paginated.products.isEmpty
              ? ProductListStatus.empty
              : ProductListStatus.loaded,
          products: paginated.products,
          skip: paginated.skip,
          limit: paginated.limit,
          total: paginated.total,
          hasMore: paginated.hasMore,
          isRefreshing: false,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        state = state.copyWith(
          isRefreshing: false,
          // Only show full error if we had no products previously
          status: state.products.isEmpty
              ? ProductListStatus.error
              : state.status,
          errorMessage: state.products.isEmpty
              ? () => failure.message
              : () => null,
        );
      },
    );
  }

  /// Infinite scroll pagination: retrieves the next page without replacing existing items.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) {
      return;
    }

    final requestId = ++_activeRequestId;
    final nextSkip = state.skip + state.products.length;

    state = state.copyWith(
      status: ProductListStatus.loadingMore,
      paginationErrorMessage: () => null,
    );

    final result = await _fetchPage(
      skip: nextSkip,
      query: state.searchQuery,
      category: state.selectedCategory,
      sort: state.sortOption,
    );

    if (requestId != _activeRequestId) return;

    result.when(
      success: (paginated) {
        final combinedProducts = [...state.products, ...paginated.products];

        state = state.copyWith(
          status: ProductListStatus.loaded,
          products: combinedProducts,
          skip: paginated.skip,
          limit: paginated.limit,
          total: paginated.total,
          hasMore: paginated.hasMore,
          paginationErrorMessage: () => null,
        );
      },
      error: (failure) {
        // Safe pagination failure: keep existing products intact!
        state = state.copyWith(
          status: ProductListStatus.loaded,
          paginationErrorMessage: () => failure.message,
        );
      },
    );
  }

  /// Debounces user input from the search text field (~400ms).
  void onSearchInput(String query) {
    _searchDebouncer.run(() {
      _applySearch(query);
    });
  }

  /// Submits the search query immediately (e.g. keyboard Enter / Action button).
  void submitSearch(String query) {
    _searchDebouncer.cancel();
    _applySearch(query);
  }

  /// Internal search executor with stale-query protection and pagination reset.
  Future<void> _applySearch(String query) async {
    final trimmed = query.trim();
    if (trimmed == state.searchQuery) return;

    final requestId = ++_activeRequestId;

    state = state.copyWith(
      status: ProductListStatus.loading,
      searchQuery: trimmed,
      skip: 0,
      errorMessage: () => null,
      paginationErrorMessage: () => null,
    );

    final result = await _fetchPage(
      skip: 0,
      query: trimmed,
      category: state.selectedCategory,
      sort: state.sortOption,
    );

    if (requestId != _activeRequestId) return;

    result.when(
      success: (paginated) {
        state = state.copyWith(
          status: paginated.products.isEmpty
              ? ProductListStatus.empty
              : ProductListStatus.loaded,
          products: paginated.products,
          skip: paginated.skip,
          limit: paginated.limit,
          total: paginated.total,
          hasMore: paginated.hasMore,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        state = state.copyWith(
          status: ProductListStatus.error,
          errorMessage: () => failure.message,
        );
      },
    );
  }

  /// Filters by category. Passing `null` or `'all'` selects all products.
  Future<void> selectCategory(String? categorySlug) async {
    final normalized = (categorySlug == null || categorySlug == 'all')
        ? null
        : categorySlug;

    if (normalized == state.selectedCategory) return;

    final requestId = ++_activeRequestId;

    state = state.copyWith(
      status: ProductListStatus.loading,
      selectedCategory: () => normalized,
      skip: 0,
      errorMessage: () => null,
      paginationErrorMessage: () => null,
    );

    final result = await _fetchPage(
      skip: 0,
      query: state.searchQuery,
      category: normalized,
      sort: state.sortOption,
    );

    if (requestId != _activeRequestId) return;

    result.when(
      success: (paginated) {
        state = state.copyWith(
          status: paginated.products.isEmpty
              ? ProductListStatus.empty
              : ProductListStatus.loaded,
          products: paginated.products,
          skip: paginated.skip,
          limit: paginated.limit,
          total: paginated.total,
          hasMore: paginated.hasMore,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        state = state.copyWith(
          status: ProductListStatus.error,
          errorMessage: () => failure.message,
        );
      },
    );
  }

  /// Sets sorting criteria and refreshes the current list.
  Future<void> setSortOption(ProductSortOption sort) async {
    if (sort == state.sortOption) return;

    final requestId = ++_activeRequestId;

    state = state.copyWith(
      status: ProductListStatus.loading,
      sortOption: sort,
      skip: 0,
      errorMessage: () => null,
      paginationErrorMessage: () => null,
    );

    final result = await _fetchPage(
      skip: 0,
      query: state.searchQuery,
      category: state.selectedCategory,
      sort: sort,
    );

    if (requestId != _activeRequestId) return;

    result.when(
      success: (paginated) {
        state = state.copyWith(
          status: paginated.products.isEmpty
              ? ProductListStatus.empty
              : ProductListStatus.loaded,
          products: paginated.products,
          skip: paginated.skip,
          limit: paginated.limit,
          total: paginated.total,
          hasMore: paginated.hasMore,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        state = state.copyWith(
          status: ProductListStatus.error,
          errorMessage: () => failure.message,
        );
      },
    );
  }

  /// Clears search query, category filter, and resets sort to default.
  Future<void> clearFilters() async {
    _searchDebouncer.cancel();

    final requestId = ++_activeRequestId;

    state = state.copyWith(
      status: ProductListStatus.loading,
      selectedCategory: () => null,
      searchQuery: '',
      sortOption: ProductSortOption.none,
      skip: 0,
      errorMessage: () => null,
      paginationErrorMessage: () => null,
    );

    final result = await _productsUseCase(
      limit: 20,
      skip: 0,
      sort: ProductSortOption.none,
    );

    if (requestId != _activeRequestId) return;

    result.when(
      success: (paginated) {
        state = state.copyWith(
          status: paginated.products.isEmpty
              ? ProductListStatus.empty
              : ProductListStatus.loaded,
          products: paginated.products,
          skip: paginated.skip,
          limit: paginated.limit,
          total: paginated.total,
          hasMore: paginated.hasMore,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        state = state.copyWith(
          status: ProductListStatus.error,
          errorMessage: () => failure.message,
        );
      },
    );
  }

  /// Dispatches the appropriate use case depending on query and category.
  Future<Result<PaginatedProducts>> _fetchPage({
    required int skip,
    required String query,
    required String? category,
    required ProductSortOption sort,
  }) {
    if (query.isNotEmpty) {
      return _searchUseCase(query: query, limit: 20, skip: skip, sort: sort);
    } else if (category != null && category.isNotEmpty && category != 'all') {
      return _categoryProductsUseCase(
        category: category,
        limit: 20,
        skip: skip,
        sort: sort,
      );
    } else {
      return _productsUseCase(limit: 20, skip: skip, sort: sort);
    }
  }
}
