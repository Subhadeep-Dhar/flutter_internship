import '../../../products/domain/entities/product.dart';

/// Pure Dart domain entity representing a single item within the shopping cart.
class CartItem {
  final int productId;
  final String title;
  final double price;
  final double? discountPercentage;
  final String thumbnail;
  final int stock;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.title,
    required this.price,
    this.discountPercentage,
    required this.thumbnail,
    this.stock = 99,
    this.quantity = 1,
  });

  /// Factory constructor to create a [CartItem] directly from a catalogue [Product].
  factory CartItem.fromProduct(Product product, {int quantity = 1}) {
    return CartItem(
      productId: product.id,
      title: product.title,
      price: product.price,
      discountPercentage: product.discountPercentage,
      thumbnail: product.thumbnail,
      stock: product.stock > 0 ? product.stock : 99,
      quantity: quantity > 0 ? quantity : 1,
    );
  }

  /// Calculates the effective unit price after applying discount (if present).
  double get effectiveUnitPrice {
    if (discountPercentage != null && discountPercentage! > 0) {
      final rawDiscounted = price * (1.0 - (discountPercentage! / 100.0));
      return (rawDiscounted * 100).round() / 100.0;
    }
    return price;
  }

  /// Line total based on effective (discounted) unit price multiplied by quantity.
  double get lineTotal => (effectiveUnitPrice * quantity * 100).round() / 100.0;

  /// Original line total before discounts.
  double get originalLineTotal => (price * quantity * 100).round() / 100.0;

  /// Total money saved on this item.
  double get totalSavings {
    final diff = originalLineTotal - lineTotal;
    return diff > 0 ? (diff * 100).round() / 100.0 : 0.0;
  }

  /// Whether the item has reached the maximum stock available.
  bool get isAtStockLimit => quantity >= stock;

  /// Creates a copy of this [CartItem] with modified properties.
  CartItem copyWith({
    int? productId,
    String? title,
    double? price,
    double? discountPercentage,
    String? thumbnail,
    int? stock,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      thumbnail: thumbnail ?? this.thumbnail,
      stock: stock ?? this.stock,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          title == other.title &&
          price == other.price &&
          discountPercentage == other.discountPercentage &&
          thumbnail == other.thumbnail &&
          stock == other.stock &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(
    productId,
    title,
    price,
    discountPercentage,
    thumbnail,
    stock,
    quantity,
  );

  @override
  String toString() =>
      'CartItem(productId: $productId, title: $title, qty: $quantity, lineTotal: $lineTotal)';
}
