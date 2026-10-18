import '../../domain/entities/product.dart';

/// Concrete DTO model representing a [Product] serialized from the DummyJSON API.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    super.discountPercentage,
    required super.rating,
    required super.stock,
    super.tags,
    super.brand,
    required super.thumbnail,
    super.images,
    super.availabilityStatus,
  });

  /// Factory constructor to deserialize a JSON object defensively.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle tags safely (may be list of dynamic or strings)
    final tagsRaw = json['tags'];
    final List<String> parsedTags;
    if (tagsRaw is List) {
      parsedTags = tagsRaw.map((e) => e.toString()).toList();
    } else {
      parsedTags = const [];
    }

    // Handle images safely
    final imagesRaw = json['images'];
    final List<String> parsedImages;
    if (imagesRaw is List) {
      parsedImages = imagesRaw.map((e) => e.toString()).toList();
    } else {
      parsedImages = const [];
    }

    // Extract thumbnail with fallback to first image if thumbnail is absent
    String resolvedThumbnail = (json['thumbnail'] as String?)?.trim() ?? '';
    if (resolvedThumbnail.isEmpty && parsedImages.isNotEmpty) {
      resolvedThumbnail = parsedImages.first;
    }

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim() ?? 'Untitled Product',
      description: (json['description'] as String?)?.trim() ?? '',
      category: (json['category'] as String?)?.trim() ?? 'general',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      tags: parsedTags,
      brand: (json['brand'] as String?)?.trim(),
      thumbnail: resolvedThumbnail,
      images: parsedImages,
      availabilityStatus: (json['availabilityStatus'] as String?)?.trim(),
    );
  }

  /// Converts this [ProductModel] to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      if (discountPercentage != null) 'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      if (brand != null) 'brand': brand,
      'thumbnail': thumbnail,
      'images': images,
      if (availabilityStatus != null) 'availabilityStatus': availabilityStatus,
    };
  }
}
