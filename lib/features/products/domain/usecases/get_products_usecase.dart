import '../../../../core/error/result.dart';
import '../entities/paginated_products.dart';
import '../entities/product_sort_option.dart';
import '../repositories/product_repository.dart';

/// Pure Dart use case to fetch a paginated list of catalogue products.
class GetProductsUseCase {
  final ProductRepository _repository;

  const GetProductsUseCase(this._repository);

  Future<Result<PaginatedProducts>> call({
    int limit = 20,
    int skip = 0,
    ProductSortOption sort = ProductSortOption.none,
  }) {
    return _repository.getProducts(limit: limit, skip: skip, sort: sort);
  }
}
