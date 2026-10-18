import 'product.dart';

/// Pure Dart container representing a paginated slice of [Product] items.
class PaginatedProducts {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const PaginatedProducts({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  /// True if there are remaining pages on the server beyond this page.
  bool get hasMore => (skip + products.length) < total;

  /// True if the current page returned no products.
  bool get isEmpty => products.isEmpty;

  /// Returns an empty container for fallback or initial scenarios.
  static const PaginatedProducts empty = PaginatedProducts(
    products: [],
    total: 0,
    skip: 0,
    limit: 0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedProducts &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          skip == other.skip &&
          limit == other.limit;

  @override
  int get hashCode => total.hashCode ^ skip.hashCode ^ limit.hashCode;

  @override
  String toString() =>
      'PaginatedProducts(count: ${products.length}, total: $total, skip: $skip, limit: $limit, hasMore: $hasMore)';
}
