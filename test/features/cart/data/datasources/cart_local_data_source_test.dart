import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';
import 'package:shopsphere/features/cart/data/models/cart_model.dart';

void main() {
  group('CartLocalDataSourceImpl Tests', () {
    late SharedPreferences prefs;
    late CartLocalDataSourceImpl dataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      dataSource = CartLocalDataSourceImpl(prefs);
    });

    test('getCart returns empty cart when no data is stored', () async {
      final cart = await dataSource.getCart();
      expect(cart.items, isEmpty);
      expect(cart.isEmpty, isTrue);
    });

    test('saveCart persists cart and getCart retrieves it intact', () async {
      const item = CartItemModel(
        productId: 10,
        title: 'Gucci Bloom',
        price: 150.0,
        discountPercentage: 10.0,
        thumbnail: 'https://gucci.jpg',
        stock: 5,
        quantity: 2,
      );
      const cartToSave = CartModel(items: [item]);

      await dataSource.saveCart(cartToSave);

      final retrieved = await dataSource.getCart();
      expect(retrieved.items.length, 1);
      expect(retrieved.items.first.productId, 10);
      expect(retrieved.items.first.title, 'Gucci Bloom');
      expect(retrieved.items.first.quantity, 2);
      expect(retrieved.grandTotal, 270.0);
    });

    test(
      'getCart recovers gracefully with empty cart when stored JSON is corrupted',
      () async {
        await prefs.setString(
          CartLocalDataSourceImpl.cartStorageKey,
          'INVALID_CORRUPTED_JSON{{{',
        );

        final cart = await dataSource.getCart();
        expect(cart.items, isEmpty);
      },
    );

    test('clearCart removes persisted storage key', () async {
      const item = CartItemModel(
        productId: 1,
        title: 'Mascara',
        price: 10.0,
        thumbnail: '',
        quantity: 1,
      );
      await dataSource.saveCart(const CartModel(items: [item]));
      expect(prefs.containsKey(CartLocalDataSourceImpl.cartStorageKey), isTrue);

      await dataSource.clearCart();
      expect(
        prefs.containsKey(CartLocalDataSourceImpl.cartStorageKey),
        isFalse,
      );

      final emptyCart = await dataSource.getCart();
      expect(emptyCart.isEmpty, isTrue);
    });
  });
}
