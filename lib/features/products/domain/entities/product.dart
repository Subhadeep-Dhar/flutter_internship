/// Pure Dart domain entity representing a Product in the catalogue.
class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double? discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String? brand;
  final String thumbnail;
  final List<String> images;
  final String? availabilityStatus;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.discountPercentage,
    required this.rating,
    required this.stock,
    this.tags = const [],
    this.brand,
    required this.thumbnail,
    this.images = const [],
    this.availabilityStatus,
  });

  /// True if the product has available inventory.
  bool get isInStock => stock > 0;

  /// True if inventory is critically low (5 or fewer units).
  bool get isLowStock => stock > 0 && stock <= 5;

  /// Effective price after applying discount, or original price if no discount.
  double get effectivePrice {
    if (discountPercentage != null && discountPercentage! > 0) {
      return price * (1 - (discountPercentage! / 100));
    }
    return price;
  }

  /// Friendly display label for stock status.
  String get stockStatusLabel {
    if (availabilityStatus != null && availabilityStatus!.isNotEmpty) {
      return availabilityStatus!;
    }
    if (stock <= 0) return 'Out of Stock';
    if (stock <= 5) return 'Only $stock left';
    return 'In Stock';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          price == other.price &&
          stock == other.stock;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ price.hashCode;

  @override
  String toString() =>
      'Product(id: $id, title: $title, price: \$$price, rating: $rating, stock: $stock)';
}
