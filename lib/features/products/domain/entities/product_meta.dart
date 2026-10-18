/// Pure Dart domain entity representing product barcode/QR and tracking metadata.
class ProductMeta {
  final String? createdAt;
  final String? updatedAt;
  final String? barcode;
  final String? qrCode;

  const ProductMeta({
    this.createdAt,
    this.updatedAt,
    this.barcode,
    this.qrCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductMeta &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          barcode == other.barcode &&
          qrCode == other.qrCode;

  @override
  int get hashCode =>
      createdAt.hashCode ^
      updatedAt.hashCode ^
      barcode.hashCode ^
      qrCode.hashCode;

  @override
  String toString() =>
      'ProductMeta(barcode: $barcode, qrCode: $qrCode, createdAt: $createdAt)';
}
