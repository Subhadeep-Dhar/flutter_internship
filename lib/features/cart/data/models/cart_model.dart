import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_item_model.dart';

/// Data Transfer Object for [Cart] supporting local storage serialization.
class CartModel extends Cart {
  const CartModel({super.items = const []});

  /// Creates a [CartModel] from a [Cart] domain entity.
  factory CartModel.fromEntity(Cart entity) {
    return CartModel(
      items: entity.items.map((item) {
        return item is CartItemModel ? item : CartItemModel.fromEntity(item);
      }).toList(),
    );
  }

  /// Deserializes a JSON map into a [CartModel].
  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is List) {
      final items = <CartItemModel>[];
      for (final raw in rawItems) {
        if (raw is Map<String, dynamic>) {
          items.add(CartItemModel.fromJson(raw));
        }
      }
      return CartModel(items: items);
    }
    return const CartModel(items: []);
  }

  /// Converts this [CartModel] into a serializable JSON map.
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) {
        if (item is CartItemModel) {
          return item.toJson();
        }
        return CartItemModel.fromEntity(item).toJson();
      }).toList(),
    };
  }

  /// Helper to create a new [CartModel] with modified items.
  @override
  CartModel copyWith({List<CartItem>? items}) {
    return CartModel(
      items: (items ?? this.items).map((item) {
        return item is CartItemModel ? item : CartItemModel.fromEntity(item);
      }).toList(),
    );
  }
}
