import 'product_dimensions.dart';
import 'product_meta.dart';
import 'review.dart';

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
  final String? sku;
  final double? weight;
  final ProductDimensions? dimensions;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? returnPolicy;
  final int? minimumOrderQuantity;
  final ProductMeta? meta;
  final List<Review> reviews;

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
    this.sku,
    this.weight,
    this.dimensions,
    this.warrantyInformation,
    this.shippingInformation,
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.meta,
    this.reviews = const [],
  });

  /// True if the product has available inventory.
  bool get isInStock => stock > 0;

  /// True if inventory is critically low (5 or fewer units).
  bool get isLowStock => stock > 0 && stock <= 5;

  /// True if discount is present and greater than 0.
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  /// Effective price after applying discount, or original price if no discount.
  double get effectivePrice {
    if (hasDiscount) {
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

  /// Number of customer reviews attached to this product.
  int get reviewCount => reviews.length;

  /// Whether this product has any reviews.
  bool get hasReviews => reviews.isNotEmpty;

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
