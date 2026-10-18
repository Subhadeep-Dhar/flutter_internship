import '../../../../core/error/result.dart';
import '../entities/category.dart';
import '../entities/paginated_products.dart';
import '../entities/product.dart';
import '../entities/product_sort_option.dart';

/// Pure Dart contract defining the product catalogue repository.
abstract interface class ProductRepository {
  /// Fetches a paginated page of products with optional sorting.
  Future<Result<PaginatedProducts>> getProducts({
    int limit = 20,
    int skip = 0,
    ProductSortOption sort = ProductSortOption.none,
  });

  /// Searches products matching [query] with pagination and optional sorting.
  Future<Result<PaginatedProducts>> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    ProductSortOption sort = ProductSortOption.none,
  });

  /// Fetches products filtered by [category] slug with pagination and optional sorting.
  Future<Result<PaginatedProducts>> getProductsByCategory({
    required String category,
    int limit = 20,
    int skip = 0,
    ProductSortOption sort = ProductSortOption.none,
  });

  /// Fetches available product categories from DummyJSON.
  Future<Result<List<Category>>> getCategories();

  /// Fetches detailed information for a single product by [id].
  Future<Result<Product>> getProductById(int id);
}
