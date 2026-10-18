/// Pure Dart domain entity representing the simulated order confirmation
/// returned by DummyJSON's POST /carts/add endpoint.
class CheckoutResult {
  final int id;
  final double total;
  final double discountedTotal;
  final int totalProducts;
  final int totalQuantity;
  final int userId;
  final DateTime timestamp;

  CheckoutResult({
    required this.id,
    required this.total,
    required this.discountedTotal,
    required this.totalProducts,
    required this.totalQuantity,
    required this.userId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          total == other.total &&
          discountedTotal == other.discountedTotal &&
          totalProducts == other.totalProducts &&
          totalQuantity == other.totalQuantity &&
          userId == other.userId;

  @override
  int get hashCode => Object.hash(
    id,
    total,
    discountedTotal,
    totalProducts,
    totalQuantity,
    userId,
  );

  @override
  String toString() =>
      'CheckoutResult(id: $id, total: $total, discounted: $discountedTotal, qty: $totalQuantity)';
}
