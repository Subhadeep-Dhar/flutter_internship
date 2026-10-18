import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/cart.dart';
import '../entities/checkout_result.dart';

/// Pure Dart contract defining shopping cart operations and simulated checkout.
abstract class CartRepository {
  /// Retrieves the user's active cart from local persistence.
  Future<Result<Cart>> getCart();

  /// Adds a [Product] with the specified [quantity] to the cart.
  /// If the item already exists, its quantity is increased.
  Future<Result<Cart>> addToCart(Product product, int quantity);

  /// Updates the quantity of an item in the cart.
  /// If [quantity] is <= 0, the item is removed.
  Future<Result<Cart>> updateQuantity(int productId, int quantity);

  /// Removes an individual product from the cart by its [productId].
  Future<Result<Cart>> removeFromCart(int productId);

  /// Removes all items from the active cart.
  Future<Result<Cart>> clearCart();

  /// Simulates checkout by sending active cart items to DummyJSON's POST /carts/add.
  /// On success, local cart is cleared and [CheckoutResult] is returned.
  Future<Result<CheckoutResult>> checkout(int userId);
}
