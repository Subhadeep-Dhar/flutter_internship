import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_sort_option.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/get_categories_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_by_category_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/search_products_usecase.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  group('Product Domain UseCases', () {
    late MockProductRepository mockRepository;

    const tProduct = Product(
      id: 1,
      title: 'Mascara',
      description: 'Test',
      category: 'beauty',
      price: 10.0,
      rating: 4.5,
      stock: 5,
      thumbnail: 'https://thumb.jpg',
    );

    const tPaginated = PaginatedProducts(
      products: [tProduct],
      total: 1,
      skip: 0,
      limit: 20,
    );

    setUp(() {
      mockRepository = MockProductRepository();
    });

    test('GetProductsUseCase delegates parameters to repository', () async {
      final useCase = GetProductsUseCase(mockRepository);

      when(
        () => mockRepository.getProducts(
          limit: 10,
          skip: 5,
          sort: ProductSortOption.ratingDesc,
        ),
      ).thenAnswer((_) async => const Result.success(tPaginated));

      final result = await useCase(
        limit: 10,
        skip: 5,
        sort: ProductSortOption.ratingDesc,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, tPaginated);
      verify(
        () => mockRepository.getProducts(
          limit: 10,
          skip: 5,
          sort: ProductSortOption.ratingDesc,
        ),
      ).called(1);
    });

    test('GetCategoriesUseCase calls repository.getCategories', () async {
      final useCase = GetCategoriesUseCase(mockRepository);
      const tCategories = [Category(slug: 'beauty', name: 'Beauty')];

      when(
        () => mockRepository.getCategories(),
      ).thenAnswer((_) async => const Result.success(tCategories));

      final result = await useCase();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, tCategories);
      verify(() => mockRepository.getCategories()).called(1);
    });

    test(
      'SearchProductsUseCase delegates query and pagination to repository',
      () async {
        final useCase = SearchProductsUseCase(mockRepository);

        when(
          () => mockRepository.searchProducts(
            query: 'perfume',
            limit: 20,
            skip: 0,
            sort: ProductSortOption.none,
          ),
        ).thenAnswer((_) async => const Result.success(tPaginated));

        final result = await useCase(query: 'perfume');

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, tPaginated);
        verify(
          () => mockRepository.searchProducts(
            query: 'perfume',
            limit: 20,
            skip: 0,
            sort: ProductSortOption.none,
          ),
        ).called(1);
      },
    );

    test(
      'GetProductsByCategoryUseCase delegates category to repository',
      () async {
        final useCase = GetProductsByCategoryUseCase(mockRepository);

        when(
          () => mockRepository.getProductsByCategory(
            category: 'beauty',
            limit: 20,
            skip: 0,
            sort: ProductSortOption.none,
          ),
        ).thenAnswer((_) async => const Result.success(tPaginated));

        final result = await useCase(category: 'beauty');

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, tPaginated);
        verify(
          () => mockRepository.getProductsByCategory(
            category: 'beauty',
            limit: 20,
            skip: 0,
            sort: ProductSortOption.none,
          ),
        ).called(1);
      },
    );

    test('GetProductByIdUseCase delegates id to repository', () async {
      final useCase = GetProductByIdUseCase(mockRepository);

      when(
        () => mockRepository.getProductById(1),
      ).thenAnswer((_) async => const Result.success(tProduct));

      final result = await useCase(1);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, tProduct);
      verify(() => mockRepository.getProductById(1)).called(1);
    });
  });
}
