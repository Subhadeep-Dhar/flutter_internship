import '../../domain/entities/product_meta.dart';

/// Data Transfer Object for [ProductMeta].
class ProductMetaModel extends ProductMeta {
  const ProductMetaModel({
    super.createdAt,
    super.updatedAt,
    super.barcode,
    super.qrCode,
  });

  /// Safely deserializes a JSON object into a [ProductMetaModel].
  factory ProductMetaModel.fromJson(Map<String, dynamic> json) {
    return ProductMetaModel(
      createdAt: (json['createdAt'] as String?)?.trim(),
      updatedAt: (json['updatedAt'] as String?)?.trim(),
      barcode: (json['barcode'] as String?)?.trim(),
      qrCode: (json['qrCode'] as String?)?.trim(),
    );
  }

  /// Converts this [ProductMetaModel] to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (barcode != null) 'barcode': barcode,
      if (qrCode != null) 'qrCode': qrCode,
    };
  }
}
