import '../../domain/entities/paginated_products.dart';
import 'product_model.dart';

/// DTO for paginated product list responses from DummyJSON endpoints:
/// `/products`, `/products/search`, and `/products/category/{category}`.
class ProductPageResponseModel {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  const ProductPageResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductPageResponseModel.fromJson(Map<String, dynamic> json) {
    final productsRaw = json['products'];
    final List<ProductModel> parsedProducts;
    if (productsRaw is List) {
      parsedProducts = productsRaw
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    } else {
      parsedProducts = const [];
    }

    return ProductPageResponseModel(
      products: parsedProducts,
      total: (json['total'] as num?)?.toInt() ?? parsedProducts.length,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? parsedProducts.length,
    );
  }

  /// Maps this response model to the pure Dart domain [PaginatedProducts] entity.
  PaginatedProducts toEntity() {
    return PaginatedProducts(
      products: products,
      total: total,
      skip: skip,
      limit: limit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => p.toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }
}
