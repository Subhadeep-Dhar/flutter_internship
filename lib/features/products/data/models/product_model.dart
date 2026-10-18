import '../../domain/entities/product.dart';
import 'product_dimensions_model.dart';
import 'product_meta_model.dart';
import 'review_model.dart';

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
    super.sku,
    super.weight,
    super.dimensions,
    super.warrantyInformation,
    super.shippingInformation,
    super.returnPolicy,
    super.minimumOrderQuantity,
    super.meta,
    super.reviews,
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

    // Handle dimensions safely
    final dimRaw = json['dimensions'];
    final ProductDimensionsModel? parsedDimensions;
    if (dimRaw is Map<String, dynamic>) {
      parsedDimensions = ProductDimensionsModel.fromJson(dimRaw);
    } else {
      parsedDimensions = null;
    }

    // Handle metadata safely
    final metaRaw = json['meta'];
    final ProductMetaModel? parsedMeta;
    if (metaRaw is Map<String, dynamic>) {
      parsedMeta = ProductMetaModel.fromJson(metaRaw);
    } else {
      parsedMeta = null;
    }

    // Handle reviews safely
    final reviewsRaw = json['reviews'];
    final List<ReviewModel> parsedReviews;
    if (reviewsRaw is List) {
      parsedReviews = reviewsRaw
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList();
    } else {
      parsedReviews = const [];
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
      sku: (json['sku'] as String?)?.trim(),
      weight: (json['weight'] as num?)?.toDouble(),
      dimensions: parsedDimensions,
      warrantyInformation: (json['warrantyInformation'] as String?)?.trim(),
      shippingInformation: (json['shippingInformation'] as String?)?.trim(),
      returnPolicy: (json['returnPolicy'] as String?)?.trim(),
      minimumOrderQuantity: (json['minimumOrderQuantity'] as num?)?.toInt(),
      meta: parsedMeta,
      reviews: parsedReviews,
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
      if (sku != null) 'sku': sku,
      if (weight != null) 'weight': weight,
      if (dimensions != null && dimensions is ProductDimensionsModel)
        'dimensions': (dimensions as ProductDimensionsModel).toJson(),
      if (warrantyInformation != null)
        'warrantyInformation': warrantyInformation,
      if (shippingInformation != null)
        'shippingInformation': shippingInformation,
      if (returnPolicy != null) 'returnPolicy': returnPolicy,
      if (minimumOrderQuantity != null)
        'minimumOrderQuantity': minimumOrderQuantity,
      if (meta != null && meta is ProductMetaModel)
        'meta': (meta as ProductMetaModel).toJson(),
      'reviews': reviews
          .map(
            (r) => r is ReviewModel
                ? r.toJson()
                : ReviewModel(
                    rating: r.rating,
                    comment: r.comment,
                    date: r.date,
                    reviewerName: r.reviewerName,
                    reviewerEmail: r.reviewerEmail,
                  ).toJson(),
          )
          .toList(),
    };
  }
}
