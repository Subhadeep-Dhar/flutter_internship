import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('ProductRemoteDataSourceImpl', () {
    late MockDio mockDio;
    late ProductRemoteDataSourceImpl dataSource;

    setUp(() {
      mockDio = MockDio();
      dataSource = ProductRemoteDataSourceImpl(mockDio);
    });

    test(
      'getProducts calls /products with query parameters and returns ProductPageResponseModel',
      () async {
        final responseData = {
          'products': [
            {
              'id': 1,
              'title': 'Lipstick',
              'category': 'beauty',
              'price': 12.99,
              'rating': 4.1,
              'stock': 10,
              'thumbnail': 'https://dummyjson.com/thumb.jpg',
            },
          ],
          'total': 1,
          'skip': 0,
          'limit': 20,
        };

        when(
          () => mockDio.get<Map<String, dynamic>>(
            ApiEndpoints.products,
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.products),
            statusCode: 200,
            data: responseData,
          ),
        );

        final result = await dataSource.getProducts(limit: 20, skip: 0);

        expect(result.products.length, 1);
        expect(result.products.first.title, 'Lipstick');
        expect(result.total, 1);

        verify(
          () => mockDio.get<Map<String, dynamic>>(
            ApiEndpoints.products,
            queryParameters: {'limit': 20, 'skip': 0},
          ),
        ).called(1);
      },
    );

    test(
      'getProducts passes sortBy and order parameters when provided',
      () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            ApiEndpoints.products,
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.products),
            statusCode: 200,
            data: {'products': [], 'total': 0, 'skip': 0, 'limit': 20},
          ),
        );

        await dataSource.getProducts(
          limit: 10,
          skip: 5,
          sortBy: 'price',
          order: 'asc',
        );

        verify(
          () => mockDio.get<Map<String, dynamic>>(
            ApiEndpoints.products,
            queryParameters: {
              'limit': 10,
              'skip': 5,
              'sortBy': 'price',
              'order': 'asc',
            },
          ),
        ).called(1);
      },
    );

    test(
      'searchProducts calls /products/search with q and pagination params',
      () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            ApiEndpoints.searchProducts,
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.searchProducts),
            statusCode: 200,
            data: {'products': [], 'total': 0, 'skip': 0, 'limit': 20},
          ),
        );

        await dataSource.searchProducts(query: 'phone', limit: 20, skip: 0);

        verify(
          () => mockDio.get<Map<String, dynamic>>(
            ApiEndpoints.searchProducts,
            queryParameters: {'q': 'phone', 'limit': 20, 'skip': 0},
          ),
        ).called(1);
      },
    );

    test('getProductsByCategory calls /products/category/{category}', () async {
      final path = ApiEndpoints.productsByCategory('beauty');
      when(
        () => mockDio.get<Map<String, dynamic>>(
          path,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {'products': [], 'total': 0, 'skip': 0, 'limit': 20},
        ),
      );

      await dataSource.getProductsByCategory(
        category: 'beauty',
        limit: 20,
        skip: 0,
      );

      verify(
        () => mockDio.get<Map<String, dynamic>>(
          path,
          queryParameters: {'limit': 20, 'skip': 0},
        ),
      ).called(1);
    });

    test(
      'getCategories calls /products/categories and parses list of categories',
      () async {
        when(() => mockDio.get<dynamic>(ApiEndpoints.categories)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.categories),
            statusCode: 200,
            data: [
              {'slug': 'beauty', 'name': 'Beauty'},
              {'slug': 'fragrances', 'name': 'Fragrances'},
            ],
          ),
        );

        final categories = await dataSource.getCategories();

        expect(categories.length, 2);
        expect(categories[0].slug, 'beauty');
        expect(categories[1].name, 'Fragrances');
      },
    );

    test(
      'getProductById calls /products/{id} and parses single ProductModel',
      () async {
        final path = ApiEndpoints.productById(5);
        when(() => mockDio.get<Map<String, dynamic>>(path)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              'id': 5,
              'title': 'Red Nail Polish',
              'category': 'beauty',
              'price': 8.99,
              'rating': 4.0,
              'stock': 15,
              'thumbnail': 'https://dummyjson.com/thumb5.jpg',
            },
          ),
        );

        final product = await dataSource.getProductById(5);

        expect(product.id, 5);
        expect(product.title, 'Red Nail Polish');
        expect(product.price, 8.99);
      },
    );
  });
}
