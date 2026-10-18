import '../../../../core/error/result.dart';
import '../entities/paginated_products.dart';
import '../entities/product_sort_option.dart';
import '../repositories/product_repository.dart';

/// Pure Dart use case to search catalogue products by query.
class SearchProductsUseCase {
  final ProductRepository _repository;

  const SearchProductsUseCase(this._repository);

  Future<Result<PaginatedProducts>> call({
    required String query,
    int limit = 20,
    int skip = 0,
    ProductSortOption sort = ProductSortOption.none,
  }) {
    return _repository.searchProducts(
      query: query,
      limit: limit,
      skip: skip,
      sort: sort,
    );
  }
}
