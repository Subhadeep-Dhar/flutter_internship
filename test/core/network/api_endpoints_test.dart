import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    test('baseUrl matches verified DummyJSON domain', () {
      expect(ApiEndpoints.baseUrl, 'https://dummyjson.com');
    });

    test('timeout durations are sensible (15s)', () {
      expect(ApiEndpoints.connectTimeout, const Duration(seconds: 15));
      expect(ApiEndpoints.receiveTimeout, const Duration(seconds: 15));
      expect(ApiEndpoints.sendTimeout, const Duration(seconds: 15));
    });

    test('generates correct parametrized product and category endpoints', () {
      expect(ApiEndpoints.productById(42), '/products/42');
      expect(
        ApiEndpoints.productsByCategory('laptops'),
        '/products/category/laptops',
      );
      expect(ApiEndpoints.userCarts(7), '/carts/user/7');
    });

    test('error simulation endpoints match assignment specification', () {
      expect(ApiEndpoints.simulate500, '/http/500');
      expect(ApiEndpoints.simulate404, '/http/404');
      expect(ApiEndpoints.nonExistentProduct, '/products/9999');
    });
  });
}
