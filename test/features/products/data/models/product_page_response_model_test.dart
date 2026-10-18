import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_page_response_model.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';

void main() {
  group('ProductPageResponseModel', () {
    final validJson = {
      'products': [
        {
          'id': 1,
          'title': 'Essence Mascara',
          'category': 'beauty',
          'price': 9.99,
          'rating': 4.5,
          'stock': 20,
          'thumbnail': 'https://dummyjson.com/thumb.jpg',
        },
        {
          'id': 2,
          'title': 'Eyeshadow Palette',
          'category': 'beauty',
          'price': 19.99,
          'rating': 4.2,
          'stock': 5,
          'thumbnail': 'https://dummyjson.com/thumb2.jpg',
        },
      ],
      'total': 100,
      'skip': 0,
      'limit': 2,
    };

    test('fromJson parses products list and pagination metadata', () {
      final model = ProductPageResponseModel.fromJson(validJson);

      expect(model.products.length, 2);
      expect(model.products.first.id, 1);
      expect(model.total, 100);
      expect(model.skip, 0);
      expect(model.limit, 2);
    });

    test('toEntity converts to PaginatedProducts correctly', () {
      final model = ProductPageResponseModel.fromJson(validJson);
      final entity = model.toEntity();

      expect(entity, isA<PaginatedProducts>());
      expect(entity.products.length, 2);
      expect(entity.total, 100);
      expect(entity.skip, 0);
      expect(entity.limit, 2);
      expect(entity.hasMore, isTrue);
      expect(entity.isEmpty, isFalse);
    });

    test('fromJson handles empty or malformed products list gracefully', () {
      final emptyJson = {'products': [], 'total': 0, 'skip': 0, 'limit': 20};

      final model = ProductPageResponseModel.fromJson(emptyJson);
      final entity = model.toEntity();

      expect(entity.products, isEmpty);
      expect(entity.total, 0);
      expect(entity.hasMore, isFalse);
      expect(entity.isEmpty, isTrue);
    });
  });
}
