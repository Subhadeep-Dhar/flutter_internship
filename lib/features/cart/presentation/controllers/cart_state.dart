import '../../domain/entities/cart.dart';
import '../../domain/entities/checkout_result.dart';

/// Explicit status values for the shopping cart state.
enum CartStatus { initial, loading, ready, checkingOut, checkoutSuccess, error }

/// Immutable UI state for the shopping cart and checkout feature.
class CartState {
  final CartStatus status;
  final Cart cart;
  final String? errorMessage;
  final CheckoutResult? checkoutResult;

  const CartState({
    this.status = CartStatus.initial,
    this.cart = const Cart(),
    this.errorMessage,
    this.checkoutResult,
  });

  bool get isInitial => status == CartStatus.initial;
  bool get isLoading => status == CartStatus.loading;
  bool get isReady => status == CartStatus.ready;
  bool get isCheckingOut => status == CartStatus.checkingOut;
  bool get isCheckoutSuccess => status == CartStatus.checkoutSuccess;
  bool get isError => status == CartStatus.error;

  int get totalItems => cart.totalItems;
  bool get isEmpty => cart.isEmpty;

  CartState copyWith({
    CartStatus? status,
    Cart? cart,
    String? Function()? errorMessage,
    CheckoutResult? Function()? checkoutResult,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      checkoutResult: checkoutResult != null
          ? checkoutResult()
          : this.checkoutResult,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          cart == other.cart &&
          errorMessage == other.errorMessage &&
          checkoutResult == other.checkoutResult;

  @override
  int get hashCode => Object.hash(status, cart, errorMessage, checkoutResult);

  @override
  String toString() =>
      'CartState(status: $status, items: ${cart.items.length}, total: ${cart.grandTotal})';
}
