import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_item_quantity_usecase.dart';
import 'cart_state.dart';

/// Riverpod 3 Notifier managing shopping cart state, local persistence,
/// and simulated checkout execution.
class CartNotifier extends Notifier<CartState> {
  final GetCartUseCase? _injectedGetCart;
  final AddToCartUseCase? _injectedAddToCart;
  final UpdateCartItemQuantityUseCase? _injectedUpdateQuantity;
  final RemoveFromCartUseCase? _injectedRemoveFromCart;
  final ClearCartUseCase? _injectedClearCart;
  final CheckoutUseCase? _injectedCheckout;

  CartNotifier({
    GetCartUseCase? getCartUseCase,
    AddToCartUseCase? addToCartUseCase,
    UpdateCartItemQuantityUseCase? updateQuantityUseCase,
    RemoveFromCartUseCase? removeFromCartUseCase,
    ClearCartUseCase? clearCartUseCase,
    CheckoutUseCase? checkoutUseCase,
  }) : _injectedGetCart = getCartUseCase,
       _injectedAddToCart = addToCartUseCase,
       _injectedUpdateQuantity = updateQuantityUseCase,
       _injectedRemoveFromCart = removeFromCartUseCase,
       _injectedClearCart = clearCartUseCase,
       _injectedCheckout = checkoutUseCase;

  GetCartUseCase get _getCartUseCase =>
      _injectedGetCart ?? ref.read(getCartUseCaseProvider);
  AddToCartUseCase get _addToCartUseCase =>
      _injectedAddToCart ?? ref.read(addToCartUseCaseProvider);
  UpdateCartItemQuantityUseCase get _updateQuantityUseCase =>
      _injectedUpdateQuantity ??
      ref.read(updateCartItemQuantityUseCaseProvider);
  RemoveFromCartUseCase get _removeFromCartUseCase =>
      _injectedRemoveFromCart ?? ref.read(removeFromCartUseCaseProvider);
  ClearCartUseCase get _clearCartUseCase =>
      _injectedClearCart ?? ref.read(clearCartUseCaseProvider);
  CheckoutUseCase get _checkoutUseCase =>
      _injectedCheckout ?? ref.read(checkoutUseCaseProvider);

  bool _hasInitialLoaded = false;

  @override
  CartState build() {
    Future.microtask(() {
      if (ref.mounted && !_hasInitialLoaded) {
        loadCart();
      }
    });

    return const CartState(status: CartStatus.initial);
  }

  /// Loads the persisted cart from local storage.
  Future<void> loadCart() async {
    _hasInitialLoaded = true;
    state = state.copyWith(status: CartStatus.loading);

    final result = await _getCartUseCase();
    if (!ref.mounted) return;

    result.when(
      success: (cart) {
        state = state.copyWith(
          status: CartStatus.ready,
          cart: cart,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        state = state.copyWith(
          status: CartStatus.error,
          errorMessage: () => failure.message,
        );
      },
    );
  }

  /// Adds a [Product] to the cart with the given [quantity].
  Future<bool> addItem(Product product, {int quantity = 1}) async {
    final result = await _addToCartUseCase(product, quantity: quantity);
    if (!ref.mounted) return false;

    return result.when(
      success: (updatedCart) {
        state = state.copyWith(
          status: CartStatus.ready,
          cart: updatedCart,
          errorMessage: () => null,
        );
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          status: CartStatus.ready,
          errorMessage: () => failure.message,
        );
        return false;
      },
    );
  }

  /// Increments the quantity of an existing cart item by 1, respecting stock limit.
  Future<void> incrementQuantity(int productId) async {
    final item = state.cart.findByProductId(productId);
    if (item == null) return;

    if (item.isAtStockLimit) {
      state = state.copyWith(
        errorMessage: () =>
            'Maximum available stock (${item.stock}) reached for this item.',
      );
      return;
    }

    await updateQuantity(productId, item.quantity + 1);
  }

  /// Decrements the quantity of an existing cart item by 1.
  /// If quantity reaches 0, the item is removed.
  Future<void> decrementQuantity(int productId) async {
    final item = state.cart.findByProductId(productId);
    if (item == null) return;

    if (item.quantity <= 1) {
      await removeItem(productId);
    } else {
      await updateQuantity(productId, item.quantity - 1);
    }
  }

  /// Explicitly updates the quantity for a product.
  Future<void> updateQuantity(int productId, int quantity) async {
    final result = await _updateQuantityUseCase(productId, quantity);
    if (!ref.mounted) return;

    result.when(
      success: (updatedCart) {
        state = state.copyWith(
          status: CartStatus.ready,
          cart: updatedCart,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        state = state.copyWith(errorMessage: () => failure.message);
      },
    );
  }

  /// Removes an item completely from the cart.
  Future<void> removeItem(int productId) async {
    final result = await _removeFromCartUseCase(productId);
    if (!ref.mounted) return;

    result.when(
      success: (updatedCart) {
        state = state.copyWith(
          status: CartStatus.ready,
          cart: updatedCart,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        state = state.copyWith(errorMessage: () => failure.message);
      },
    );
  }

  /// Clears all items from the cart.
  Future<void> clearCart() async {
    final result = await _clearCartUseCase();
    if (!ref.mounted) return;

    result.when(
      success: (emptyCart) {
        state = state.copyWith(
          status: CartStatus.ready,
          cart: emptyCart,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        state = state.copyWith(errorMessage: () => failure.message);
      },
    );
  }

  /// Performs simulated checkout order creation via DummyJSON.
  Future<bool> checkout({int? userId}) async {
    if (state.cart.isEmpty) {
      state = state.copyWith(
        errorMessage: () =>
            'Your cart is empty. Add items before placing an order.',
      );
      return false;
    }

    int resolvedUserId = userId ?? 1;
    final user = ref.read(authNotifierProvider).userOrNull;
    if (userId == null && user != null) {
      resolvedUserId = user.id;
    }

    state = state.copyWith(
      status: CartStatus.checkingOut,
      errorMessage: () => null,
    );

    final result = await _checkoutUseCase(userId: resolvedUserId);
    if (!ref.mounted) return false;

    return result.when(
      success: (checkoutResult) {
        state = state.copyWith(
          status: CartStatus.checkoutSuccess,
          cart: const Cart(items: []),
          checkoutResult: () => checkoutResult,
          errorMessage: () => null,
        );
        return true;
      },
      error: (failure) {
        state = state.copyWith(
          status: CartStatus.ready,
          errorMessage: () => failure.message,
        );
        return false;
      },
    );
  }

  /// Clears the error banner or message.
  void clearErrorMessage() {
    state = state.copyWith(errorMessage: () => null);
  }

  /// Resets state after successful checkout confirmation has been dismissed.
  void dismissCheckoutSuccess() {
    state = state.copyWith(
      status: CartStatus.ready,
      checkoutResult: () => null,
    );
  }
}
