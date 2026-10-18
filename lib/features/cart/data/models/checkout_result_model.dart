import '../../domain/entities/checkout_result.dart';

/// Data Transfer Object for [CheckoutResult] deserializing DummyJSON's POST /carts/add response.
class CheckoutResultModel extends CheckoutResult {
  CheckoutResultModel({
    required super.id,
    required super.total,
    required super.discountedTotal,
    required super.totalProducts,
    required super.totalQuantity,
    required super.userId,
    super.timestamp,
  });

  /// Deserializes DummyJSON cart addition response safely.
  factory CheckoutResultModel.fromJson(Map<String, dynamic> json) {
    return CheckoutResultModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountedTotal:
          (json['discountedTotal'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 1,
      timestamp: DateTime.now(),
    );
  }

  /// Converts this [CheckoutResultModel] to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total': total,
      'discountedTotal': discountedTotal,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
