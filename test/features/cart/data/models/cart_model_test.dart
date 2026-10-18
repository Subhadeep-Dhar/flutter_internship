import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';
import 'package:shopsphere/features/cart/data/models/cart_model.dart';
import 'package:shopsphere/features/cart/data/models/checkout_result_model.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

void main() {
  group('Cart & CartItem Domain & Model Tests', () {
    const tProduct = Product(
      id: 1,
      title: 'Essence Mascara',
      description: 'Volumizing lash mascara',
      category: 'beauty',
      price: 10.0,
      discountPercentage: 20.0, // 20% discount -> effective price $8.00
      rating: 4.8,
      stock: 5,
      thumbnail: 'https://thumb.jpg',
    );

    test(
      'CartItem.fromProduct computes effective prices and totals accurately',
      () {
        final item = CartItem.fromProduct(tProduct, quantity: 3);

        expect(item.productId, 1);
        expect(item.title, 'Essence Mascara');
        expect(item.price, 10.0);
        expect(item.discountPercentage, 20.0);
        expect(item.effectiveUnitPrice, 8.0);
        expect(item.quantity, 3);
        expect(item.originalLineTotal, 30.0);
        expect(item.lineTotal, 24.0);
        expect(item.totalSavings, 6.0);
        expect(item.isAtStockLimit, isFalse);
      },
    );

    test('CartItem detects stock limit correctly', () {
      final item = CartItem.fromProduct(tProduct, quantity: 5);
      expect(item.isAtStockLimit, isTrue);

      final itemExceeding = CartItem.fromProduct(tProduct, quantity: 6);
      expect(itemExceeding.isAtStockLimit, isTrue);
    });

    test(
      'CartItemModel serializes and deserializes cleanly with fromJson/toJson',
      () {
        final model = CartItemModel(
          productId: 42,
          title: 'Running Shoes',
          price: 99.99,
          discountPercentage: 10.0,
          thumbnail: 'https://img.jpg',
          stock: 15,
          quantity: 2,
        );

        final json = model.toJson();
        expect(json['productId'], 42);
        expect(json['price'], 99.99);
        expect(json['quantity'], 2);

        final deserialized = CartItemModel.fromJson(json);
        expect(deserialized.productId, model.productId);
        expect(deserialized.title, model.title);
        expect(deserialized.effectiveUnitPrice, 89.99);
        expect(deserialized.lineTotal, 179.98);
        expect(deserialized.stock, 15);
        expect(deserialized.quantity, 2);
      },
    );

    test('CartItemModel.fromJson parses nulls and malformed types safely', () {
      final item = CartItemModel.fromJson(const {});
      expect(item.productId, 0);
      expect(item.title, '');
      expect(item.price, 0.0);
      expect(item.discountPercentage, isNull);
      expect(item.stock, 99);
      expect(item.quantity, 1);
    });

    test(
      'Cart computes subtotal, discounts, and grandTotal across multiple items',
      () {
        final item1 = CartItem.fromProduct(
          tProduct,
          quantity: 2,
        ); // eff $8, orig $10
        final item2 = CartItem(
          productId: 2,
          title: 'Lipstick',
          price: 25.0,
          discountPercentage: null, // no discount
          thumbnail: 'https://lip.jpg',
          stock: 10,
          quantity: 1,
        );

        final cart = Cart(items: [item1, item2]);

        expect(cart.uniqueItemCount, 2);
        expect(cart.totalItems, 3);
        expect(cart.subtotal, 45.0); // 2*10 + 1*25 = 45.0
        expect(cart.totalDiscount, 4.0); // 2*2 = 4.0
        expect(cart.grandTotal, 41.0); // 2*8 + 1*25 = 41.0
        expect(cart.isEmpty, isFalse);
        expect(cart.isNotEmpty, isTrue);
        expect(cart.containsProduct(1), isTrue);
        expect(cart.containsProduct(99), isFalse);
      },
    );

    test('CartModel serializes and deserializes empty and populated lists', () {
      final item = CartItemModel(
        productId: 5,
        title: 'Shampoo',
        price: 12.50,
        thumbnail: 'https://shampoo.jpg',
        quantity: 2,
      );

      final model = CartModel(items: [item]);
      final json = model.toJson();
      expect(json['items'], isA<List>());
      expect((json['items'] as List).length, 1);

      final deserialized = CartModel.fromJson(json);
      expect(deserialized.items.length, 1);
      expect(deserialized.items.first.title, 'Shampoo');

      final emptyDeserialized = CartModel.fromJson(const {});
      expect(emptyDeserialized.items, isEmpty);
      expect(emptyDeserialized.isEmpty, isTrue);
    });

    test(
      'CheckoutResultModel deserializes DummyJSON cart addition response',
      () {
        final dummyJsonResponse = <String, dynamic>{
          'id': 51,
          'products': [
            {
              'id': 144,
              'quantity': 4,
              'total': 39.96,
              'discountedTotal': 35.78,
            },
          ],
          'total': 39.96,
          'discountedTotal': 35.78,
          'userId': 1,
          'totalProducts': 1,
          'totalQuantity': 4,
        };

        final result = CheckoutResultModel.fromJson(dummyJsonResponse);
        expect(result.id, 51);
        expect(result.total, 39.96);
        expect(result.discountedTotal, 35.78);
        expect(result.userId, 1);
        expect(result.totalProducts, 1);
        expect(result.totalQuantity, 4);

        final json = result.toJson();
        expect(json['id'], 51);
        expect(json['totalQuantity'], 4);
      },
    );
  });
}
