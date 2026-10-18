import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_sort_option.dart';

/// Status states for the product catalogue.
enum ProductListStatus { initial, loading, loaded, loadingMore, empty, error }

/// Represents the catalogue operation that encountered a failure.
enum FailedOperation { none, initialLoad, refresh, loadMore }

/// Comprehensive, immutable state model for the product catalogue.
class ProductListState {
  final ProductListStatus status;
  final List<Product> products;
  final List<Category> categories;
  final String? selectedCategory; // null or 'all' represents All
  final String searchQuery;
  final ProductSortOption sortOption;
  final int skip;
  final int limit;
  final int total;
  final bool hasMore;
  final String? errorMessage;
  final String? paginationErrorMessage;
  final String? bannerErrorMessage;
  final FailedOperation failedOperation;
  final bool isRefreshing;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.sortOption = ProductSortOption.none,
    this.skip = 0,
    this.limit = 20,
    this.total = 0,
    this.hasMore = true,
    this.errorMessage,
    this.paginationErrorMessage,
    this.bannerErrorMessage,
    this.failedOperation = FailedOperation.none,
    this.isRefreshing = false,
  });

  /// Factory for the clean initial state.
  factory ProductListState.initial() => const ProductListState();

  bool get isInitial => status == ProductListStatus.initial;
  bool get isLoading => status == ProductListStatus.loading;
  bool get isLoaded => status == ProductListStatus.loaded;
  bool get isLoadingMore => status == ProductListStatus.loadingMore;
  bool get isEmpty => status == ProductListStatus.empty;
  bool get isError => status == ProductListStatus.error;
  bool get hasProducts => products.isNotEmpty;

  /// Returns true if either search, category filter, or non-default sort is active.
  bool get hasActiveFilters =>
      (selectedCategory != null && selectedCategory != 'all') ||
      searchQuery.trim().isNotEmpty ||
      sortOption != ProductSortOption.none;

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    List<Category>? categories,
    String? Function()? selectedCategory,
    String? searchQuery,
    ProductSortOption? sortOption,
    int? skip,
    int? limit,
    int? total,
    bool? hasMore,
    String? Function()? errorMessage,
    String? Function()? paginationErrorMessage,
    String? Function()? bannerErrorMessage,
    FailedOperation? failedOperation,
    bool? isRefreshing,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory != null
          ? selectedCategory()
          : this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      paginationErrorMessage: paginationErrorMessage != null
          ? paginationErrorMessage()
          : this.paginationErrorMessage,
      bannerErrorMessage: bannerErrorMessage != null
          ? bannerErrorMessage()
          : this.bannerErrorMessage,
      failedOperation: failedOperation ?? this.failedOperation,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductListState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          selectedCategory == other.selectedCategory &&
          searchQuery == other.searchQuery &&
          sortOption == other.sortOption &&
          skip == other.skip &&
          limit == other.limit &&
          total == other.total &&
          hasMore == other.hasMore &&
          products.length == other.products.length &&
          errorMessage == other.errorMessage &&
          paginationErrorMessage == other.paginationErrorMessage &&
          bannerErrorMessage == other.bannerErrorMessage &&
          failedOperation == other.failedOperation &&
          isRefreshing == other.isRefreshing;

  @override
  int get hashCode =>
      status.hashCode ^
      selectedCategory.hashCode ^
      searchQuery.hashCode ^
      sortOption.hashCode ^
      skip.hashCode ^
      limit.hashCode ^
      total.hashCode ^
      hasMore.hashCode ^
      bannerErrorMessage.hashCode ^
      failedOperation.hashCode ^
      isRefreshing.hashCode;
}
