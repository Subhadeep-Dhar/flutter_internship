import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/checkout_result.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';

/// Implementation of [CartRepository] orchestrating local cart caching
/// and simulated checkout submission via [CartRemoteDataSource].
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  final CartRemoteDataSource remoteDataSource;

  const CartRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Result<Cart>> getCart() async {
    try {
      final cart = await localDataSource.getCart();
      return Result.success(cart);
    } catch (e) {
      return Result.error(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Result<Cart>> addToCart(Product product, int quantity) async {
    if (quantity <= 0) {
      return const Result.error(
        ValidationFailure(message: 'Quantity must be at least 1.'),
      );
    }

    if (!product.isInStock) {
      return const Result.error(
        ValidationFailure(message: 'This product is currently out of stock.'),
      );
    }

    try {
      final currentCart = await localDataSource.getCart();

      if (currentCart.isFull) {
        return const Result.error(
          ValidationFailure(
            message:
                'Your cart is full. Remove an item or reduce quantities to add more.',
          ),
        );
      }

      final items = List<CartItem>.from(currentCart.items);
      final existingIndex = items.indexWhere(
        (item) => item.productId == product.id,
      );

      final availableStock = product.stock > 0 ? product.stock : 99;
      final existingInCart = existingIndex >= 0
          ? items[existingIndex].quantity
          : 0;
      final remainingStock = (availableStock - existingInCart).clamp(
        0,
        availableStock,
      );
      final remainingCapacity = currentCart.remainingCapacity;
      final maxAddable = remainingStock < remainingCapacity
          ? remainingStock
          : remainingCapacity;

      if (maxAddable <= 0) {
        if (existingInCart >= availableStock) {
          return Result.error(
            ValidationFailure(
              message:
                  'Cannot add more. You already have the maximum available stock ($availableStock) in your cart.',
            ),
          );
        } else {
          return const Result.error(
            ValidationFailure(
              message:
                  'Your cart is full. Remove an item or reduce quantities to add more.',
            ),
          );
        }
      }

      if (quantity > maxAddable) {
        return Result.error(
          ValidationFailure(
            message:
                'Cannot add $quantity units. Only $maxAddable more can be added to your cart.',
          ),
        );
      }

      if (existingIndex >= 0) {
        final existing = items[existingIndex];
        final finalQuantity = existing.quantity + quantity;

        items[existingIndex] = existing.copyWith(
          quantity: finalQuantity,
          stock: availableStock,
          price: product.price,
          discountPercentage: product.discountPercentage,
          title: product.title,
          thumbnail: product.thumbnail,
        );
      } else {
        items.add(
          CartItem.fromProduct(
            product,
            quantity: quantity,
          ).copyWith(stock: availableStock),
        );
      }

      final updatedCart = CartModel.fromEntity(Cart(items: items));
      await localDataSource.saveCart(updatedCart);
      return Result.success(updatedCart);
    } catch (e) {
      return Result.error(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Result<Cart>> updateQuantity(int productId, int quantity) async {
    try {
      final currentCart = await localDataSource.getCart();
      final items = List<CartItem>.from(currentCart.items);
      final index = items.indexWhere((item) => item.productId == productId);

      if (index < 0) {
        return const Result.error(
          NotFoundFailure(message: 'Item not found in cart.'),
        );
      }

      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        final item = items[index];
        final maxStock = item.stock > 0 ? item.stock : 99;
        final otherItemsUnits = currentCart.totalItems - item.quantity;
        final maxAllowedByCart = Cart.maxCapacity - otherItemsUnits;
        final upperLimit = maxStock < maxAllowedByCart
            ? maxStock
            : maxAllowedByCart;
        final clampedQty = quantity > upperLimit ? upperLimit : quantity;
        items[index] = item.copyWith(quantity: clampedQty);
      }

      final updatedCart = CartModel.fromEntity(Cart(items: items));
      await localDataSource.saveCart(updatedCart);
      return Result.success(updatedCart);
    } catch (e) {
      return Result.error(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Result<Cart>> removeFromCart(int productId) async {
    try {
      final currentCart = await localDataSource.getCart();
      final items = currentCart.items
          .where((item) => item.productId != productId)
          .toList();

      final updatedCart = CartModel.fromEntity(Cart(items: items));
      await localDataSource.saveCart(updatedCart);
      return Result.success(updatedCart);
    } catch (e) {
      return Result.error(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Result<Cart>> clearCart() async {
    try {
      await localDataSource.clearCart();
      return const Result.success(Cart(items: []));
    } catch (e) {
      return Result.error(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Result<CheckoutResult>> checkout(int userId) async {
    try {
      final currentCart = await localDataSource.getCart();
      if (currentCart.isEmpty) {
        return const Result.error(
          ValidationFailure(
            message:
                'Your cart is empty. Add products before placing an order.',
          ),
        );
      }

      final result = await remoteDataSource.checkout(
        userId: userId,
        items: currentCart.items.map(CartItemModel.fromEntity).toList(),
      );

      // On successful remote simulation, clear the local cart
      await localDataSource.clearCart();
      return Result.success(result);
    } catch (e) {
      // If remote submission fails, local cart is kept intact
      return Result.error(ErrorHandler.handle(e));
    }
  }
}
