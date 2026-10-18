import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

void main() {
  group('ProductModel', () {
    final fullJson = {
      'id': 10,
      'title': 'Premium Wireless Headphones',
      'description': 'Noise cancelling over-ear headphones.',
      'category': 'audio',
      'price': 199.99,
      'discountPercentage': 15.0,
      'rating': 4.75,
      'stock': 12,
      'tags': ['audio', 'bluetooth'],
      'brand': 'AudioMax',
      'thumbnail': 'https://dummyjson.com/thumb.jpg',
      'images': [
        'https://dummyjson.com/img1.jpg',
        'https://dummyjson.com/img2.jpg',
      ],
      'availabilityStatus': 'In Stock',
    };

    test('is a subtype of Product domain entity', () {
      final model = ProductModel.fromJson(fullJson);
      expect(model, isA<Product>());
    });

    test('fromJson parses complete payload correctly', () {
      final model = ProductModel.fromJson(fullJson);

      expect(model.id, 10);
      expect(model.title, 'Premium Wireless Headphones');
      expect(model.description, 'Noise cancelling over-ear headphones.');
      expect(model.category, 'audio');
      expect(model.price, 199.99);
      expect(model.discountPercentage, 15.0);
      expect(model.rating, 4.75);
      expect(model.stock, 12);
      expect(model.tags, ['audio', 'bluetooth']);
      expect(model.brand, 'AudioMax');
      expect(model.thumbnail, 'https://dummyjson.com/thumb.jpg');
      expect(model.images.length, 2);
      expect(model.availabilityStatus, 'In Stock');
      expect(model.isInStock, isTrue);
      expect(model.isLowStock, isFalse);
      expect(model.effectivePrice, closeTo(169.99, 0.01));
    });

    test('fromJson handles null or missing optional fields defensively', () {
      final minimalJson = {'id': 20, 'title': 'Basic Mouse', 'price': 25.0};

      final model = ProductModel.fromJson(minimalJson);

      expect(model.id, 20);
      expect(model.title, 'Basic Mouse');
      expect(model.description, '');
      expect(model.category, 'general');
      expect(model.price, 25.0);
      expect(model.discountPercentage, isNull);
      expect(model.rating, 0.0);
      expect(model.stock, 0);
      expect(model.tags, isEmpty);
      expect(model.brand, isNull);
      expect(model.thumbnail, '');
      expect(model.images, isEmpty);
      expect(model.availabilityStatus, isNull);
      expect(model.isInStock, isFalse);
      expect(model.stockStatusLabel, 'Out of Stock');
      expect(model.effectivePrice, 25.0);
    });

    test('falls back to first image when thumbnail is missing', () {
      final json = {
        'id': 30,
        'title': 'Webcam',
        'price': 49.99,
        'images': ['https://dummyjson.com/fallback.jpg'],
      };

      final model = ProductModel.fromJson(json);
      expect(model.thumbnail, 'https://dummyjson.com/fallback.jpg');
    });

    test('stockStatusLabel identifies low stock', () {
      final json = {
        'id': 40,
        'title': 'Limited Edition Mug',
        'price': 15.0,
        'stock': 3,
      };

      final model = ProductModel.fromJson(json);
      expect(model.isInStock, isTrue);
      expect(model.isLowStock, isTrue);
      expect(model.stockStatusLabel, 'Only 3 left');
    });

    test('toJson serializes correctly', () {
      final model = ProductModel.fromJson(fullJson);
      final json = model.toJson();

      expect(json['id'], 10);
      expect(json['title'], 'Premium Wireless Headphones');
      expect(json['price'], 199.99);
      expect(json['discountPercentage'], 15.0);
      expect(json['brand'], 'AudioMax');
      expect(json['tags'], ['audio', 'bluetooth']);
    });
  });
}
