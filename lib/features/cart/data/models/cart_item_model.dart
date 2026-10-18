import '../../domain/entities/cart_item.dart';

/// Data Transfer Object for [CartItem] with defensive JSON parsing and serialization.
class CartItemModel extends CartItem {
  const CartItemModel({
    required super.productId,
    required super.title,
    required super.price,
    super.discountPercentage,
    required super.thumbnail,
    super.stock = 99,
    super.quantity = 1,
  });

  /// Creates a [CartItemModel] from a [CartItem] domain entity.
  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      productId: entity.productId,
      title: entity.title,
      price: entity.price,
      discountPercentage: entity.discountPercentage,
      thumbnail: entity.thumbnail,
      stock: entity.stock,
      quantity: entity.quantity,
    );
  }

  /// Deserializes JSON safely, with default fallbacks for missing or null properties.
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      thumbnail: (json['thumbnail'] as String?)?.trim() ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 99,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  /// Converts this [CartItemModel] into a serializable JSON map.
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      if (discountPercentage != null) 'discountPercentage': discountPercentage,
      'thumbnail': thumbnail,
      'stock': stock,
      'quantity': quantity,
    };
  }
}
