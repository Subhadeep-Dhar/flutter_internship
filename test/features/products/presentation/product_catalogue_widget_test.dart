import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/controllers/auth_state.dart';
import 'package:shopsphere/features/products/domain/entities/category.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/controllers/product_list_notifier.dart';
import 'package:shopsphere/features/products/presentation/controllers/product_list_state.dart';
import 'package:shopsphere/features/products/presentation/pages/home_page.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';

class FakeAuthNotifier extends AuthNotifier {
  final AuthState initialState;
  FakeAuthNotifier([
    this.initialState = const AuthState.authenticated(
      user: User(
        id: 1,
        username: 'emilys',
        email: 'emily@example.com',
        firstName: 'Emily',
        lastName: 'Johnson',
      ),
    ),
  ]);

  @override
  AuthState build() => initialState;
}

class FakeProductListNotifier extends ProductListNotifier {
  final ProductListState initialState;
  bool loadInitialCalled = false;
  bool retryCalled = false;
  bool clearFiltersCalled = false;
  String? selectedCategoryParam;
  String? searchInputParam;

  FakeProductListNotifier([this.initialState = const ProductListState()]);

  @override
  ProductListState build() => initialState;

  @override
  Future<void> loadInitial() async {
    loadInitialCalled = true;
  }

  @override
  Future<void> retry() async {
    retryCalled = true;
    if (initialState.failedOperation == FailedOperation.initialLoad ||
        initialState.products.isEmpty) {
      loadInitialCalled = true;
    }
  }

  @override
  Future<void> selectCategory(String? categorySlug) async {
    selectedCategoryParam = categorySlug;
  }

  @override
  void onSearchInput(String query) {
    searchInputParam = query;
  }

  @override
  Future<void> clearFilters() async {
    clearFiltersCalled = true;
  }
}

void main() {
  const tProduct = Product(
    id: 101,
    title: 'Wireless Earbuds',
    description: 'High fidelity audio',
    category: 'electronics',
    price: 49.99,
    discountPercentage: 20.0,
    rating: 4.6,
    stock: 8,
    thumbnail: '',
    availabilityStatus: 'In Stock',
  );

  const tCategories = [
    Category(slug: 'electronics', name: 'Electronics'),
    Category(slug: 'beauty', name: 'Beauty'),
  ];

  Widget createWidgetUnderTest({
    required ProductListState productState,
    FakeProductListNotifier? fakeNotifier,
  }) {
    final notifier = fakeNotifier ?? FakeProductListNotifier(productState);

    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(FakeAuthNotifier.new),
        productListNotifierProvider.overrideWith(() => notifier),
      ],
      child: MaterialApp(theme: AppTheme.lightTheme, home: const HomePage()),
    );
  }

  group('Product Catalogue Widget Tests', () {
    testWidgets(
      'renders ProductCard with title, category, rating, price, and discount badge',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 220,
                  child: ProductCard(product: tProduct),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Wireless Earbuds'), findsOneWidget);
        expect(find.text('ELECTRONICS'), findsOneWidget);
        expect(find.text('4.6'), findsOneWidget);
        expect(find.text('\$39.99'), findsOneWidget); // Discounted price
        expect(find.text('\$49.99'), findsOneWidget); // Struck-through original
        expect(find.text('-20%'), findsOneWidget); // Discount badge
      },
    );

    testWidgets(
      'renders search bar, category chips, and product cards when loaded',
      (tester) async {
        final loadedState = ProductListState(
          status: ProductListStatus.loaded,
          products: [tProduct],
          categories: tCategories,
          total: 1,
        );

        await tester.pumpWidget(
          createWidgetUnderTest(productState: loadedState),
        );
        await tester.pump();

        expect(find.text('ShopSphere'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Electronics'), findsOneWidget);
        expect(find.text('Beauty'), findsOneWidget);
        expect(find.text('Wireless Earbuds'), findsOneWidget);
      },
    );

    testWidgets('tapping category chip invokes selectCategory', (tester) async {
      final fakeNotifier = FakeProductListNotifier(
        ProductListState(
          status: ProductListStatus.loaded,
          products: [tProduct],
          categories: tCategories,
          total: 1,
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          productState: fakeNotifier.initialState,
          fakeNotifier: fakeNotifier,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Electronics'));
      await tester.pump();

      expect(fakeNotifier.selectedCategoryParam, 'electronics');
    });

    testWidgets('typing in search bar invokes onSearchInput', (tester) async {
      final fakeNotifier = FakeProductListNotifier(
        ProductListState(
          status: ProductListStatus.loaded,
          products: [tProduct],
          categories: tCategories,
          total: 1,
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          productState: fakeNotifier.initialState,
          fakeNotifier: fakeNotifier,
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'headphones');
      await tester.pump();

      expect(fakeNotifier.searchInputParam, 'headphones');
    });

    testWidgets(
      'renders empty view when status is empty and triggers clearFilters',
      (tester) async {
        final fakeNotifier = FakeProductListNotifier(
          const ProductListState(
            status: ProductListStatus.empty,
            products: [],
            searchQuery: 'nonexistent',
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productState: fakeNotifier.initialState,
            fakeNotifier: fakeNotifier,
          ),
        );
        await tester.pump();

        expect(find.text('No products found'), findsOneWidget);
        expect(find.text('Reset Catalogue'), findsOneWidget);

        await tester.tap(find.text('Reset Catalogue'));
        await tester.pump();

        expect(fakeNotifier.clearFiltersCalled, isTrue);
      },
    );

    testWidgets(
      'renders error view when status is error and retry triggers loadInitial',
      (tester) async {
        final fakeNotifier = FakeProductListNotifier(
          const ProductListState(
            status: ProductListStatus.error,
            products: [],
            errorMessage: 'Server unavailable (500)',
            failedOperation: FailedOperation.initialLoad,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productState: fakeNotifier.initialState,
            fakeNotifier: fakeNotifier,
          ),
        );
        await tester.pump();

        expect(find.text('Server unavailable (500)'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pump();

        expect(fakeNotifier.loadInitialCalled, isTrue);
      },
    );

    testWidgets(
      'initial catalogue failure renders visible error and Retry button without scrolling',
      (tester) async {
        final fakeNotifier = FakeProductListNotifier(
          const ProductListState(
            status: ProductListStatus.error,
            products: [],
            errorMessage:
                'No internet connection. Please check your network and retry.',
            failedOperation: FailedOperation.initialLoad,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productState: fakeNotifier.initialState,
            fakeNotifier: fakeNotifier,
          ),
        );
        await tester.pump();

        // 1. Error message and Retry button must be present in widget tree
        final errorFinder = find.text(
          'No internet connection. Please check your network and retry.',
        );
        final retryFinder = find.widgetWithText(FilledButton, 'Retry');

        expect(errorFinder, findsOneWidget);
        expect(retryFinder, findsOneWidget);

        // 2. Both must be immediately visible without scrolling (within viewport)
        final retryCenter = tester.getCenter(retryFinder);
        expect(retryCenter.dy, greaterThan(0));
        expect(retryCenter.dy, lessThan(600));

        // 3. Tapping Retry must succeed directly without requiring any scroll
        await tester.tap(retryFinder);
        await tester.pump();

        expect(fakeNotifier.retryCalled, isTrue);
        expect(fakeNotifier.loadInitialCalled, isTrue);
      },
    );

    testWidgets(
      'failed refresh displays a top-level banner while existing products remain visible',
      (tester) async {
        final fakeNotifier = FakeProductListNotifier(
          const ProductListState(
            status: ProductListStatus.loaded,
            products: [tProduct],
            bannerErrorMessage:
                'Could not refresh catalogue. Check connection.',
            failedOperation: FailedOperation.refresh,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productState: fakeNotifier.initialState,
            fakeNotifier: fakeNotifier,
          ),
        );
        await tester.pump();

        // 1. Persistent top-level banner is displayed
        final bannerFinder = find.byKey(const ValueKey('product_error_banner'));
        expect(bannerFinder, findsOneWidget);
        expect(
          find.text('Could not refresh catalogue. Check connection.'),
          findsOneWidget,
        );

        // 2. Existing product items are preserved and visible
        final productFinder = find.text('Wireless Earbuds');
        expect(productFinder, findsOneWidget);

        // 3. Top-level banner is positioned above the product grid
        final bannerTop = tester.getTopLeft(bannerFinder).dy;
        final productTop = tester.getTopLeft(productFinder).dy;
        expect(bannerTop, lessThan(productTop));

        // 4. Retry button in top-level banner is clickable
        final retryButton = find.byKey(const ValueKey('banner_retry_button'));
        expect(retryButton, findsOneWidget);
        await tester.tap(retryButton);
        await tester.pump();

        expect(fakeNotifier.retryCalled, isTrue);
      },
    );

    testWidgets(
      'failed pagination request displays top-level banner while list is scrolled to top',
      (tester) async {
        final fakeNotifier = FakeProductListNotifier(
          const ProductListState(
            status: ProductListStatus.loaded,
            products: [tProduct],
            paginationErrorMessage: 'Unable to load more items.',
            bannerErrorMessage: 'Unable to load more items.',
            failedOperation: FailedOperation.loadMore,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productState: fakeNotifier.initialState,
            fakeNotifier: fakeNotifier,
          ),
        );
        await tester.pump();

        // 1. Persistent top-level banner is rendered immediately outside scroll view
        final bannerFinder = find.byKey(const ValueKey('product_error_banner'));
        expect(bannerFinder, findsOneWidget);
        expect(
          find.text('Unable to load more items.'),
          findsAtLeastNWidgets(1),
        );

        // 2. Banner and its Retry button are visible without scrolling
        final retryButton = find.byKey(const ValueKey('banner_retry_button'));
        expect(retryButton, findsOneWidget);
        final retryCenter = tester.getCenter(retryButton);
        expect(retryCenter.dy, greaterThan(0));
        expect(retryCenter.dy, lessThan(600));

        // 3. Tapping Retry in top-level banner dispatches retry
        await tester.tap(retryButton);
        await tester.pump();

        expect(fakeNotifier.retryCalled, isTrue);
      },
    );

    testWidgets('tapping ProductCard navigates to /product/:id route', (
      tester,
    ) async {
      final loadedState = ProductListState(
        status: ProductListStatus.loaded,
        products: [tProduct],
        categories: tCategories,
        total: 1,
      );

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/product/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return Scaffold(body: Text('Product Detail Screen #$id'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(FakeAuthNotifier.new),
            productListNotifierProvider.overrideWith(
              () => FakeProductListNotifier(loadedState),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Wireless Earbuds'), findsOneWidget);

      await tester.tap(find.text('Wireless Earbuds'));
      await tester.pumpAndSettle();

      expect(find.text('Product Detail Screen #101'), findsOneWidget);
    });
  });
}
