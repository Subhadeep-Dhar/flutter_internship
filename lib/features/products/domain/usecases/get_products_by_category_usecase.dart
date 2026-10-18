import '../../../../core/error/result.dart';
import '../entities/paginated_products.dart';
import '../entities/product_sort_option.dart';
import '../repositories/product_repository.dart';

/// Pure Dart use case to fetch catalogue products by category.
class GetProductsByCategoryUseCase {
  final ProductRepository _repository;

  const GetProductsByCategoryUseCase(this._repository);

  Future<Result<PaginatedProducts>> call({
    required String category,
    int limit = 20,
    int skip = 0,
    ProductSortOption sort = ProductSortOption.none,
  }) {
    return _repository.getProductsByCategory(
      category: category,
      limit: limit,
      skip: skip,
      sort: sort,
    );
  }
}
