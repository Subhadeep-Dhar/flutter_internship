import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/category_model.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/data/models/product_page_response_model.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';
import 'package:shopsphere/features/products/domain/entities/product_sort_option.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

void main() {
  group('ProductRepositoryImpl', () {
    late MockProductRemoteDataSource mockRemoteDataSource;
    late ProductRepositoryImpl repository;

    final tProductModel = ProductModel(
      id: 1,
      title: 'Essence Mascara',
      description: 'Lash princess',
      category: 'beauty',
      price: 9.99,
      rating: 4.5,
      stock: 10,
      thumbnail: 'https://dummyjson.com/thumb.jpg',
    );

    final tPageResponse = ProductPageResponseModel(
      products: [tProductModel],
      total: 1,
      skip: 0,
      limit: 20,
    );

    setUp(() {
      mockRemoteDataSource = MockProductRemoteDataSource();
      repository = ProductRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    test('getProducts returns Result.success on datasource success', () async {
      when(
        () => mockRemoteDataSource.getProducts(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sortBy: any(named: 'sortBy'),
          order: any(named: 'order'),
        ),
      ).thenAnswer((_) async => tPageResponse);

      final result = await repository.getProducts(
        limit: 20,
        skip: 0,
        sort: ProductSortOption.priceAsc,
      );

      expect(result.isSuccess, isTrue);
      final paginated = result.dataOrNull!;
      expect(paginated.products.length, 1);
      expect(paginated.products.first.id, 1);
      expect(paginated.total, 1);

      verify(
        () => mockRemoteDataSource.getProducts(
          limit: 20,
          skip: 0,
          sortBy: 'price',
          order: 'asc',
        ),
      ).called(1);
    });

    test('getProducts maps SocketException to NetworkFailure', () async {
      when(
        () => mockRemoteDataSource.getProducts(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sortBy: any(named: 'sortBy'),
          order: any(named: 'order'),
        ),
      ).thenThrow(const SocketException('Failed host lookup'));

      final result = await repository.getProducts();

      expect(result.isError, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('getProducts maps DioException 500 to ServerFailure', () async {
      when(
        () => mockRemoteDataSource.getProducts(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sortBy: any(named: 'sortBy'),
          order: any(named: 'order'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/products'),
          response: Response(
            requestOptions: RequestOptions(path: '/products'),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.getProducts();

      expect(result.isError, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
    });

    test(
      'searchProducts returns Result.success with matching products',
      () async {
        when(
          () => mockRemoteDataSource.searchProducts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            sortBy: any(named: 'sortBy'),
            order: any(named: 'order'),
          ),
        ).thenAnswer((_) async => tPageResponse);

        final result = await repository.searchProducts(query: 'mascara');

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.products.first.title, 'Essence Mascara');

        verify(
          () => mockRemoteDataSource.searchProducts(
            query: 'mascara',
            limit: 20,
            skip: 0,
            sortBy: null,
            order: null,
          ),
        ).called(1);
      },
    );

    test(
      'getProductsByCategory delegates category slug and returns Result.success',
      () async {
        when(
          () => mockRemoteDataSource.getProductsByCategory(
            category: any(named: 'category'),
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            sortBy: any(named: 'sortBy'),
            order: any(named: 'order'),
          ),
        ).thenAnswer((_) async => tPageResponse);

        final result = await repository.getProductsByCategory(
          category: 'beauty',
        );

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.products.length, 1);

        verify(
          () => mockRemoteDataSource.getProductsByCategory(
            category: 'beauty',
            limit: 20,
            skip: 0,
            sortBy: null,
            order: null,
          ),
        ).called(1);
      },
    );

    test(
      'getCategories returns list of Category entities on success',
      () async {
        final tCategories = [
          const CategoryModel(slug: 'beauty', name: 'Beauty'),
          const CategoryModel(slug: 'fragrances', name: 'Fragrances'),
        ];

        when(
          () => mockRemoteDataSource.getCategories(),
        ).thenAnswer((_) async => tCategories);

        final result = await repository.getCategories();

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.length, 2);
        expect(result.dataOrNull!.first.slug, 'beauty');
      },
    );

    test(
      'getProductById returns Product on success and NotFoundFailure on 404',
      () async {
        when(
          () => mockRemoteDataSource.getProductById(1),
        ).thenAnswer((_) async => tProductModel);

        final successResult = await repository.getProductById(1);
        expect(successResult.isSuccess, isTrue);
        expect(successResult.dataOrNull!.id, 1);

        when(() => mockRemoteDataSource.getProductById(9999)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/products/9999'),
            response: Response(
              requestOptions: RequestOptions(path: '/products/9999'),
              statusCode: 404,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final errorResult = await repository.getProductById(9999);
        expect(errorResult.isError, isTrue);
        expect(errorResult.failureOrNull, isA<NotFoundFailure>());
      },
    );
  });
}
