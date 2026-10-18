/// Pure Dart domain entity representing 3D package dimensions of a product.
class ProductDimensions {
  final double? width;
  final double? height;
  final double? depth;

  const ProductDimensions({this.width, this.height, this.depth});

  /// Formatted dimension string (e.g., "23.2 × 14.4 × 28.0 cm"), or null if all null.
  String? get formatted {
    if (width == null && height == null && depth == null) return null;
    final w = width?.toStringAsFixed(1) ?? '-';
    final h = height?.toStringAsFixed(1) ?? '-';
    final d = depth?.toStringAsFixed(1) ?? '-';
    return '$w × $h × $d cm';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductDimensions &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          depth == other.depth;

  @override
  int get hashCode => width.hashCode ^ height.hashCode ^ depth.hashCode;

  @override
  String toString() => 'ProductDimensions($formatted)';
}
