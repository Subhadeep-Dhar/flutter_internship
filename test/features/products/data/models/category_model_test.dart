import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/category_model.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';

void main() {
  group('CategoryModel', () {
    test('is a subtype of Category domain entity', () {
      final model = CategoryModel.fromJson({
        'slug': 'beauty',
        'name': 'Beauty',
      });
      expect(model, isA<Category>());
    });

    test('fromJson parses object payload with slug, name, and url', () {
      final json = {
        'slug': 'home-decoration',
        'name': 'Home Decoration',
        'url': 'https://dummyjson.com/products/category/home-decoration',
      };

      final model = CategoryModel.fromJson(json);

      expect(model.slug, 'home-decoration');
      expect(model.name, 'Home Decoration');
      expect(
        model.url,
        'https://dummyjson.com/products/category/home-decoration',
      );
    });

    test('fromJson formats slug into name when name is absent', () {
      final json = {'slug': 'kitchen-accessories'};

      final model = CategoryModel.fromJson(json);

      expect(model.slug, 'kitchen-accessories');
      expect(model.name, 'Kitchen Accessories');
    });

    test('fromJson parses string representation correctly', () {
      const rawString = 'smartphones';

      final model = CategoryModel.fromJson(rawString);

      expect(model.slug, 'smartphones');
      expect(model.name, 'Smartphones');
      expect(model.url, isNull);
    });

    test('fromJson handles invalid or null input defensively', () {
      final model = CategoryModel.fromJson(null);

      expect(model.slug, '');
      expect(model.name, 'Unknown');
    });

    test('toJson serializes correctly', () {
      final model = CategoryModel.fromJson({
        'slug': 'laptops',
        'name': 'Laptops',
        'url': 'https://dummyjson.com/products/category/laptops',
      });

      final json = model.toJson();

      expect(json['slug'], 'laptops');
      expect(json['name'], 'Laptops');
      expect(json['url'], 'https://dummyjson.com/products/category/laptops');
    });
  });
}
