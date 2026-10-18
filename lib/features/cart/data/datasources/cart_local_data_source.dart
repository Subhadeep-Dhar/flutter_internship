import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_model.dart';

/// Contract for local shopping cart persistence.
abstract class CartLocalDataSource {
  /// Loads the active cart from local storage.
  Future<CartModel> getCart();

  /// Persists the active cart to local storage.
  Future<void> saveCart(CartModel cart);

  /// Clears the stored cart.
  Future<void> clearCart();
}

/// Implementation of [CartLocalDataSource] backed by [SharedPreferences].
class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String cartStorageKey = 'shopsphere_active_cart_v1';

  final SharedPreferences _prefs;

  const CartLocalDataSourceImpl(this._prefs);

  @override
  Future<CartModel> getCart() async {
    final rawJson = _prefs.getString(cartStorageKey);
    if (rawJson == null || rawJson.trim().isEmpty) {
      return const CartModel(items: []);
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return CartModel.fromJson(decoded);
      }
      return const CartModel(items: []);
    } catch (_) {
      // If persisted JSON was somehow corrupted, gracefully return empty cart
      return const CartModel(items: []);
    }
  }

  @override
  Future<void> saveCart(CartModel cart) async {
    final encoded = jsonEncode(cart.toJson());
    await _prefs.setString(cartStorageKey, encoded);
  }

  @override
  Future<void> clearCart() async {
    await _prefs.remove(cartStorageKey);
  }
}
