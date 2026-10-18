import 'cart_item.dart';

/// Pure Dart domain entity representing the user's active shopping cart.
class Cart {
  /// Maximum total units permitted across all items in the shopping cart.
  static const int maxCapacity = 99;

  final List<CartItem> items;

  const Cart({this.items = const []});

  /// Total count of individual units in the cart across all items.
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Count of distinct product lines in the cart.
  int get uniqueItemCount => items.length;

  /// Whether the cart has reached its maximum unit capacity.
  bool get isFull => totalItems >= maxCapacity;

  /// Remaining capacity before reaching the maximum limit.
  int get remainingCapacity => (maxCapacity - totalItems).clamp(0, maxCapacity);

  /// Calculates the maximum additional quantity of a product that can be added to the cart,
  /// accounting for available stock, quantity already in the cart, and total cart capacity.
  int maxAddableForProduct(int productStock, int productId) {
    if (productStock <= 0) return 0;
    if (isFull) return 0;
    final inCart = findByProductId(productId)?.quantity ?? 0;
    final remainingStock = (productStock - inCart).clamp(0, productStock);
    return remainingStock < remainingCapacity
        ? remainingStock
        : remainingCapacity;
  }

  /// Whether the cart is currently empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the cart contains at least one item.
  bool get isNotEmpty => items.isNotEmpty;

  /// Original pre-discount subtotal for all items.
  double get subtotal {
    final raw = items.fold(0.0, (sum, item) => sum + item.originalLineTotal);
    return (raw * 100).round() / 100.0;
  }

  /// Total discount saved across all items.
  double get totalDiscount {
    final raw = items.fold(0.0, (sum, item) => sum + item.totalSavings);
    return (raw * 100).round() / 100.0;
  }

  /// Final grand total payable after discounts.
  double get grandTotal {
    final raw = items.fold(0.0, (sum, item) => sum + item.lineTotal);
    return (raw * 100).round() / 100.0;
  }

  /// Finds an item in the cart by product ID, returning null if not found.
  CartItem? findByProductId(int productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  /// Returns whether a product is already present in the cart.
  bool containsProduct(int productId) =>
      items.any((item) => item.productId == productId);

  /// Creates a copy of this [Cart] with modified items.
  Cart copyWith({List<CartItem>? items}) {
    return Cart(items: items ?? this.items);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cart &&
          runtimeType == other.runtimeType &&
          _listEquals(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);

  static bool _listEquals(List<CartItem> a, List<CartItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'Cart(items: ${items.length}, totalItems: $totalItems, grandTotal: $grandTotal)';
}
