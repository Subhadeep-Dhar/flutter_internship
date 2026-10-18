import '../../domain/entities/product_dimensions.dart';

/// Data Transfer Object for [ProductDimensions].
class ProductDimensionsModel extends ProductDimensions {
  const ProductDimensionsModel({super.width, super.height, super.depth});

  /// Safely deserializes a JSON object into a [ProductDimensionsModel].
  factory ProductDimensionsModel.fromJson(Map<String, dynamic> json) {
    return ProductDimensionsModel(
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      depth: (json['depth'] as num?)?.toDouble(),
    );
  }

  /// Converts this [ProductDimensionsModel] to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (depth != null) 'depth': depth,
    };
  }
}
