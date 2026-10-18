import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';
import 'package:shopsphere/features/products/domain/entities/paginated_products.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_sort_option.dart';
import 'package:shopsphere/features/products/domain/usecases/get_categories_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_by_category_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopsphere/features/products/domain/usecases/search_products_usecase.dart';
import 'package:shopsphere/features/products/presentation/controllers/product_list_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}

class MockGetProductsByCategoryUseCase extends Mock
    implements GetProductsByCategoryUseCase {}

void main() {
  group('ProductListNotifier', () {
    late MockGetProductsUseCase mockGetProductsUseCase;
    late MockGetCategoriesUseCase mockGetCategoriesUseCase;
    late MockSearchProductsUseCase mockSearchProductsUseCase;
    late MockGetProductsByCategoryUseCase mockGetProductsByCategoryUseCase;

    const tProduct1 = Product(
      id: 1,
      title: 'Product 1',
      description: 'Desc 1',
      category: 'beauty',
      price: 10.0,
      rating: 4.5,
      stock: 10,
      thumbnail: 'https://thumb1.jpg',
    );

    const tProduct2 = Product(
      id: 2,
      title: 'Product 2',
      description: 'Desc 2',
      category: 'beauty',
      price: 20.0,
      rating: 4.0,
      stock: 5,
      thumbnail: 'https://thumb2.jpg',
    );

    const tCategories = [
      Category(slug: 'beauty', name: 'Beauty'),
      Category(slug: 'fragrances', name: 'Fragrances'),
    ];

    const tInitialPage = PaginatedProducts(
      products: [tProduct1],
      total: 2,
      skip: 0,
      limit: 1,
    );

    const tSecondPage = PaginatedProducts(
      products: [tProduct2],
      total: 2,
      skip: 1,
      limit: 1,
    );

    setUpAll(() {
      registerFallbackValue(ProductSortOption.none);
    });

    setUp(() {
      mockGetProductsUseCase = MockGetProductsUseCase();
      mockGetCategoriesUseCase = MockGetCategoriesUseCase();
      mockSearchProductsUseCase = MockSearchProductsUseCase();
      mockGetProductsByCategoryUseCase = MockGetProductsByCategoryUseCase();

      when(
        () => mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const Result.success(tCategories));
      when(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((_) async => const Result.success(tInitialPage));
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          getProductsUseCaseProvider.overrideWithValue(mockGetProductsUseCase),
          getCategoriesUseCaseProvider.overrideWithValue(
            mockGetCategoriesUseCase,
          ),
          searchProductsUseCaseProvider.overrideWithValue(
            mockSearchProductsUseCase,
          ),
          getProductsByCategoryUseCaseProvider.overrideWithValue(
            mockGetProductsByCategoryUseCase,
          ),
        ],
      );
    }

    test('initial state is ProductListStatus.initial', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(productListNotifierProvider);
      expect(state.status, ProductListStatus.initial);
      expect(state.products, isEmpty);
    });

    test('loadInitial fetches categories and first page of products', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(productListNotifierProvider.notifier);
      await notifier.loadInitial();

      final state = container.read(productListNotifierProvider);
      expect(state.status, ProductListStatus.loaded);
      expect(state.products.length, 1);
      expect(state.products.first.id, 1);
      expect(state.categories.length, 2);
      expect(state.hasMore, isTrue);
    });

    test('loadInitial emits error when product request fails', () async {
      when(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer(
        (_) async =>
            const Result.error(NetworkFailure(message: 'Connection timed out')),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(productListNotifierProvider.notifier);
      await notifier.loadInitial();

      final state = container.read(productListNotifierProvider);
      expect(state.status, ProductListStatus.error);
      expect(state.errorMessage, 'Connection timed out');
      expect(state.products, isEmpty);
    });

    test('loadInitial emits empty when product list is empty', () async {
      when(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((_) async => const Result.success(PaginatedProducts.empty));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(productListNotifierProvider.notifier);
      await notifier.loadInitial();

      final state = container.read(productListNotifierProvider);
      expect(state.status, ProductListStatus.empty);
      expect(state.products, isEmpty);
    });

    test('loadMore appends new items and updates pagination state', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(productListNotifierProvider.notifier);
      await notifier.loadInitial();

      // Configure second page response
      when(
        () => mockGetProductsUseCase(
          limit: any(named: 'limit'),
          skip: 1,
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((_) async => const Result.success(tSecondPage));

      await notifier.loadMore();

      final state = container.read(productListNotifierProvider);
      expect(state.status, ProductListStatus.loaded);
      expect(state.products.length, 2);
      expect(state.products[0].id, 1);
      expect(state.products[1].id, 2);
      expect(state.hasMore, isFalse);
    });

    test(
      'loadMore ignores duplicate calls while already loading more',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(productListNotifierProvider.notifier);
        await notifier.loadInitial();

        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => const Result.success(tSecondPage));

        // Fire loadMore concurrently
        final f1 = notifier.loadMore();
        final f2 = notifier.loadMore();
        await Future.wait([f1, f2]);

        // Should only have called getProducts for next page once
        verify(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 1,
            sort: any(named: 'sort'),
          ),
        ).called(1);
      },
    );

    test(
      'loadMore preserves existing products and exposes bannerErrorMessage when pagination fails',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(productListNotifierProvider.notifier);
        await notifier.loadInitial();

        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 1,
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async => const Result.error(
            ServerFailure(
              message: 'Failed to fetch next page',
              statusCode: 500,
            ),
          ),
        );

        await notifier.loadMore();

        final state = container.read(productListNotifierProvider);
        // Status remains loaded, existing products are preserved, errors and failedOperation are set
        expect(state.status, ProductListStatus.loaded);
        expect(state.products.length, 1);
        expect(state.paginationErrorMessage, 'Failed to fetch next page');
        expect(state.bannerErrorMessage, 'Failed to fetch next page');
        expect(state.failedOperation, FailedOperation.loadMore);
      },
    );

    test(
      'refresh preserves existing products and displays banner on failure',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(productListNotifierProvider.notifier);
        await notifier.loadInitial();

        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 0,
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async =>
              const Result.error(NetworkFailure(message: 'Network offline')),
        );

        await notifier.refresh();

        final state = container.read(productListNotifierProvider);
        expect(state.status, ProductListStatus.loaded);
        expect(state.products.length, 1);
        expect(state.bannerErrorMessage, 'Network offline');
        expect(state.failedOperation, FailedOperation.refresh);
      },
    );

    test(
      'retry after failed refresh clears banner and loads refreshed products',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(productListNotifierProvider.notifier);
        await notifier.loadInitial();

        // Simulate refresh failure
        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 0,
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async =>
              const Result.error(NetworkFailure(message: 'Network offline')),
        );

        await notifier.refresh();
        expect(
          container.read(productListNotifierProvider).bannerErrorMessage,
          'Network offline',
        );

        // Simulate successful recovery
        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 0,
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => const Result.success(tInitialPage));

        await notifier.retry();

        final state = container.read(productListNotifierProvider);
        expect(state.bannerErrorMessage, isNull);
        expect(state.failedOperation, FailedOperation.none);
        expect(state.products.length, 1);
      },
    );

    test(
      'retry after failed pagination clears banner and appends next page',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(productListNotifierProvider.notifier);
        await notifier.loadInitial();

        // Simulate pagination failure
        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 1,
            sort: any(named: 'sort'),
          ),
        ).thenAnswer(
          (_) async =>
              const Result.error(NetworkFailure(message: 'Pagination timeout')),
        );

        await notifier.loadMore();
        expect(
          container.read(productListNotifierProvider).bannerErrorMessage,
          'Pagination timeout',
        );

        // Simulate successful recovery
        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 1,
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => const Result.success(tSecondPage));

        await notifier.retry();

        final state = container.read(productListNotifierProvider);
        expect(state.bannerErrorMessage, isNull);
        expect(state.paginationErrorMessage, isNull);
        expect(state.failedOperation, FailedOperation.none);
        expect(state.products.length, 2);
      },
    );

    test(
      'pagination retry deduplicates products and prevents concurrent overlapping requests',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(productListNotifierProvider.notifier);
        await notifier.loadInitial();

        // Second page returns both tProduct1 (duplicate) and tProduct2
        const tOverlappingSecondPage = PaginatedProducts(
          products: [tProduct1, tProduct2],
          total: 2,
          skip: 1,
          limit: 2,
        );

        when(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 1,
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => const Result.success(tOverlappingSecondPage));

        // Concurrent retries
        final f1 = notifier.retry();
        final f2 = notifier.retry();
        await Future.wait([f1, f2]);

        final state = container.read(productListNotifierProvider);
        // Product 1 should NOT be duplicated
        expect(state.products.length, 2);
        expect(state.products.map((p) => p.id).toList(), [1, 2]);

        // Repository should only have been called once for skip: 1
        verify(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: 1,
            sort: any(named: 'sort'),
          ),
        ).called(1);
      },
    );

    test(
      'selectCategory resets pagination and loads category products',
      () async {
        const tCategoryPage = PaginatedProducts(
          products: [tProduct2],
          total: 1,
          skip: 0,
          limit: 1,
        );

        when(
          () => mockGetProductsByCategoryUseCase(
            category: 'fragrances',
            limit: any(named: 'limit'),
            skip: 0,
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => const Result.success(tCategoryPage));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(productListNotifierProvider.notifier);
        await notifier.selectCategory('fragrances');

        final state = container.read(productListNotifierProvider);
        expect(state.status, ProductListStatus.loaded);
        expect(state.selectedCategory, 'fragrances');
        expect(state.products.length, 1);
        expect(state.products.first.id, 2);

        verify(
          () => mockGetProductsByCategoryUseCase(
            category: 'fragrances',
            limit: 20,
            skip: 0,
            sort: ProductSortOption.none,
          ),
        ).called(1);
      },
    );

    test('selectCategory null or all resets category filter', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(productListNotifierProvider.notifier);
      await notifier.selectCategory('all');

      final state = container.read(productListNotifierProvider);
      expect(state.selectedCategory, isNull);
    });

    test(
      'submitSearch resets pagination and searches matching products',
      () async {
        const tSearchPage = PaginatedProducts(
          products: [tProduct1],
          total: 1,
          skip: 0,
          limit: 1,
        );

        when(
          () => mockSearchProductsUseCase(
            query: 'mascara',
            limit: any(named: 'limit'),
            skip: 0,
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => const Result.success(tSearchPage));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(productListNotifierProvider.notifier);
        notifier.submitSearch('mascara');
        await Future<void>.delayed(Duration.zero);

        final state = container.read(productListNotifierProvider);
        expect(state.searchQuery, 'mascara');
        expect(state.products.length, 1);

        verify(
          () => mockSearchProductsUseCase(
            query: 'mascara',
            limit: 20,
            skip: 0,
            sort: ProductSortOption.none,
          ),
        ).called(1);
      },
    );

    test('setSortOption updates sort and refetches products', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(productListNotifierProvider.notifier);
      await notifier.setSortOption(ProductSortOption.priceAsc);

      final state = container.read(productListNotifierProvider);
      expect(state.sortOption, ProductSortOption.priceAsc);

      verify(
        () => mockGetProductsUseCase(
          limit: 20,
          skip: 0,
          sort: ProductSortOption.priceAsc,
        ),
      ).called(1);
    });

    test(
      'clearFilters resets search, category, sort, and reloads catalogue',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(productListNotifierProvider.notifier);
        await notifier.clearFilters();

        final state = container.read(productListNotifierProvider);
        expect(state.searchQuery, isEmpty);
        expect(state.selectedCategory, isNull);
        expect(state.sortOption, ProductSortOption.none);
        expect(state.products.length, 1);
      },
    );
  });
}
