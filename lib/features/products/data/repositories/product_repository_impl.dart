import '../../../../core/error/error_handler.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/paginated_products.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_sort_option.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

/// Concrete implementation of [ProductRepository] consuming [ProductRemoteDataSource].
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  const ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<PaginatedProducts>> getProducts({
    int limit = 20,
    int skip = 0,
    ProductSortOption sort = ProductSortOption.none,
  }) async {
    try {
      final response = await remoteDataSource.getProducts(
        limit: limit,
        skip: skip,
        sortBy: sort.sortBy,
        order: sort.order,
      );
      return Result.success(response.toEntity());
    } catch (e) {
      return Result.error(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Result<PaginatedProducts>> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    ProductSortOption sort = ProductSortOption.none,
  }) async {
    try {
      final response = await remoteDataSource.searchProducts(
        query: query,
        limit: limit,
        skip: skip,
        sortBy: sort.sortBy,
        order: sort.order,
      );
      return Result.success(response.toEntity());
    } catch (e) {
      return Result.error(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Result<PaginatedProducts>> getProductsByCategory({
    required String category,
    int limit = 20,
    int skip = 0,
    ProductSortOption sort = ProductSortOption.none,
  }) async {
    try {
      final response = await remoteDataSource.getProductsByCategory(
        category: category,
        limit: limit,
        skip: skip,
        sortBy: sort.sortBy,
        order: sort.order,
      );
      return Result.success(response.toEntity());
    } catch (e) {
      return Result.error(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final models = await remoteDataSource.getCategories();
      return Result.success(models);
    } catch (e) {
      return Result.error(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Result<Product>> getProductById(int id) async {
    try {
      final model = await remoteDataSource.getProductById(id);
      return Result.success(model);
    } catch (e) {
      return Result.error(ErrorHandler.handle(e));
    }
  }
}
