import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_dimensions_model.dart';
import 'package:shopsphere/features/products/data/models/product_meta_model.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/data/models/review_model.dart';

void main() {
  group('ProductModel & Detail Serialization Tests', () {
    final tFullJson = <String, dynamic>{
      'id': 1,
      'title': 'Essence Mascara Lash Princess',
      'description':
          'The Essence Mascara Lash Princess is a popular mascara known for volumizing effects.',
      'category': 'beauty',
      'price': 9.99,
      'discountPercentage': 7.17,
      'rating': 4.94,
      'stock': 5,
      'tags': ['beauty', 'mascara'],
      'brand': 'Essence',
      'sku': 'RCH45Q1A',
      'weight': 2.0,
      'dimensions': {'width': 23.17, 'height': 14.43, 'depth': 28.01},
      'warrantyInformation': '1 month warranty',
      'shippingInformation': 'Ships in 1 month',
      'availabilityStatus': 'Low Stock',
      'reviews': [
        {
          'rating': 5,
          'comment': 'Awesome product!',
          'date': '2024-05-23T08:56:21.618Z',
          'reviewerName': 'John Doe',
          'reviewerEmail': 'john.doe@x.dummyjson.com',
        },
        {
          'rating': 4,
          'comment': 'Really good mascara',
          'date': '2024-05-24T10:00:00.000Z',
          'reviewerName': 'Jane Smith',
        },
      ],
      'returnPolicy': '30 days return policy',
      'minimumOrderQuantity': 24,
      'meta': {
        'createdAt': '2024-05-23T08:56:21.618Z',
        'updatedAt': '2024-05-23T08:56:21.618Z',
        'barcode': '9164035105686',
        'qrCode': 'https://assets.dummyjson.com/public/qr-code.png',
      },
      'images': [
        'https://cdn.dummyjson.com/products/images/beauty/1.png',
        'https://cdn.dummyjson.com/products/images/beauty/2.png',
      ],
      'thumbnail': 'https://cdn.dummyjson.com/products/images/beauty/thumb.png',
    };

    test('correctly parses full JSON with all specifications and reviews', () {
      final model = ProductModel.fromJson(tFullJson);

      expect(model.id, 1);
      expect(model.title, 'Essence Mascara Lash Princess');
      expect(model.category, 'beauty');
      expect(model.brand, 'Essence');
      expect(model.price, 9.99);
      expect(model.discountPercentage, 7.17);
      expect(model.rating, 4.94);
      expect(model.stock, 5);
      expect(model.isLowStock, isTrue);
      expect(model.isInStock, isTrue);
      expect(model.sku, 'RCH45Q1A');
      expect(model.weight, 2.0);
      expect(model.warrantyInformation, '1 month warranty');
      expect(model.shippingInformation, 'Ships in 1 month');
      expect(model.returnPolicy, '30 days return policy');
      expect(model.minimumOrderQuantity, 24);

      // Dimensions verification
      expect(model.dimensions, isNotNull);
      expect(model.dimensions!.width, 23.17);
      expect(model.dimensions!.height, 14.43);
      expect(model.dimensions!.depth, 28.01);
      expect(model.dimensions!.formatted, '23.2 × 14.4 × 28.0 cm');

      // Meta verification
      expect(model.meta, isNotNull);
      expect(model.meta!.barcode, '9164035105686');
      expect(
        model.meta!.qrCode,
        'https://assets.dummyjson.com/public/qr-code.png',
      );

      // Reviews verification
      expect(model.reviews.length, 2);
      final r1 = model.reviews.first;
      expect(r1.rating, 5.0);
      expect(r1.comment, 'Awesome product!');
      expect(r1.reviewerName, 'John Doe');
      expect(r1.reviewerEmail, 'john.doe@x.dummyjson.com');
      expect(r1.formattedDate, 'May 23, 2024');

      final r2 = model.reviews.last;
      expect(r2.reviewerEmail, isNull);
      expect(r2.formattedDate, 'May 24, 2024');
    });

    test('defensively parses minimal JSON with missing optional fields', () {
      final minimalJson = <String, dynamic>{
        'id': 99,
        'title': 'Minimal Product',
        'price': 15.0,
      };

      final model = ProductModel.fromJson(minimalJson);

      expect(model.id, 99);
      expect(model.title, 'Minimal Product');
      expect(model.description, isEmpty);
      expect(model.category, 'general');
      expect(model.brand, isNull);
      expect(model.discountPercentage, isNull);
      expect(model.rating, 0.0);
      expect(model.stock, 0);
      expect(model.isInStock, isFalse);
      expect(model.tags, isEmpty);
      expect(model.images, isEmpty);
      expect(model.thumbnail, isEmpty);
      expect(model.sku, isNull);
      expect(model.weight, isNull);
      expect(model.dimensions, isNull);
      expect(model.warrantyInformation, isNull);
      expect(model.shippingInformation, isNull);
      expect(model.returnPolicy, isNull);
      expect(model.minimumOrderQuantity, isNull);
      expect(model.meta, isNull);
      expect(model.reviews, isEmpty);
      expect(model.reviewCount, 0);
      expect(model.hasReviews, isFalse);
    });

    test('ReviewModel handles missing or malformed dates gracefully', () {
      const review1 = ReviewModel(
        rating: 4.0,
        comment: 'Good',
        reviewerName: 'Alice',
        date: null,
      );
      expect(review1.parsedDate, isNull);
      expect(review1.formattedDate, '');

      const review2 = ReviewModel(
        rating: 3.0,
        comment: 'Average',
        reviewerName: 'Bob',
        date: 'not-a-valid-date',
      );
      expect(review2.parsedDate, isNull);
      expect(review2.formattedDate, 'not-a-valid-date');
    });

    test(
      'ProductDimensionsModel returns null formatted when all dimensions null',
      () {
        const dims = ProductDimensionsModel(
          width: null,
          height: null,
          depth: null,
        );
        expect(dims.formatted, isNull);
      },
    );

    test('ProductMetaModel deserializes and serializes accurately', () {
      final metaJson = <String, dynamic>{
        'createdAt': '2024-05-23T08:56:21.618Z',
        'updatedAt': '2024-05-23T08:56:21.618Z',
        'barcode': '9164921548688',
        'qrCode': 'https://assets.dummyjson.com/public/qr-code.png',
      };
      final meta = ProductMetaModel.fromJson(metaJson);
      expect(meta.barcode, '9164921548688');
      expect(meta.qrCode, 'https://assets.dummyjson.com/public/qr-code.png');
      expect(meta.toJson(), metaJson);
    });

    test('toJson produces expected structure with optional fields', () {
      final model = ProductModel.fromJson(tFullJson);
      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Essence Mascara Lash Princess');
      expect(json['sku'], 'RCH45Q1A');
      expect(json['reviews'], isA<List>());
      expect((json['reviews'] as List).length, 2);
    });
  });
}
