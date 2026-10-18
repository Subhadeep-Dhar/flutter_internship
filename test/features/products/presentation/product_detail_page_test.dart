import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/widgets/app_empty_view.dart';
import 'package:shopsphere/core/widgets/app_error_view.dart';
import 'package:shopsphere/core/widgets/app_loading_indicator.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_dimensions.dart';
import 'package:shopsphere/features/products/domain/entities/product_meta.dart';
import 'package:shopsphere/features/products/domain/entities/review.dart';
import 'package:shopsphere/features/products/presentation/controllers/product_detail_notifier.dart';
import 'package:shopsphere/features/products/presentation/controllers/product_detail_state.dart';
import 'package:shopsphere/features/products/presentation/pages/product_detail_page.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_image_gallery.dart';

class FakeProductDetailNotifier extends ProductDetailNotifier {
  final ProductDetailState initialState;
  bool retryCalled = false;

  FakeProductDetailNotifier(super.productId, this.initialState);

  @override
  ProductDetailState build() => initialState;

  @override
  Future<void> retry() async {
    retryCalled = true;
  }
}

void main() {
  const tFullProduct = Product(
    id: 10,
    title: 'Gucci Bloom Eau de Parfum',
    description: 'Capturing the spirit of contemporary and diverse women.',
    category: 'fragrances',
    price: 150.0,
    discountPercentage: 10.0,
    rating: 4.85,
    stock: 4,
    brand: 'Gucci',
    thumbnail: 'https://thumb.jpg',
    images: ['https://img1.jpg', 'https://img2.jpg'],
    sku: 'GC-BLOOM-100',
    weight: 250.0,
    dimensions: ProductDimensions(width: 10.0, height: 15.0, depth: 5.0),
    warrantyInformation: '1 year limited warranty',
    shippingInformation: 'Free express shipping',
    returnPolicy: '30 days hassle-free return',
    minimumOrderQuantity: 1,
    meta: ProductMeta(barcode: '1234567890123'),
    reviews: [
      Review(
        rating: 5.0,
        comment: 'Absolutely intoxicating floral scent!',
        date: '2024-05-15T08:00:00.000Z',
        reviewerName: 'Sophia Miller',
      ),
      Review(
        rating: 4.0,
        comment: 'Long lasting and elegant.',
        date: '2024-05-18T12:00:00.000Z',
        reviewerName: 'Emma Watson',
      ),
    ],
  );

  Widget createWidgetUnderTest({
    required int productId,
    required ProductDetailState detailState,
    FakeProductDetailNotifier? fakeNotifier,
  }) {
    final notifier =
        fakeNotifier ?? FakeProductDetailNotifier(productId, detailState);

    return ProviderScope(
      overrides: [
        productDetailNotifierProvider(productId).overrideWith(() => notifier),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: ProductDetailPage(productId: productId),
      ),
    );
  }

  group('ProductDetailPage Widget Tests', () {
    testWidgets('renders loading indicator when status is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          productId: 10,
          detailState: const ProductDetailState(
            status: ProductDetailStatus.loading,
            productId: 10,
          ),
        ),
      );

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      expect(find.text('Loading product details...'), findsOneWidget);
    });

    testWidgets('renders AppErrorView with retry button on error state', (
      tester,
    ) async {
      final fakeNotifier = FakeProductDetailNotifier(
        10,
        const ProductDetailState(
          status: ProductDetailStatus.error,
          errorMessage: 'Server connection timeout',
          productId: 10,
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          productId: 10,
          detailState: fakeNotifier.initialState,
          fakeNotifier: fakeNotifier,
        ),
      );

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Server connection timeout'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(fakeNotifier.retryCalled, isTrue);
    });

    testWidgets('renders invalid product view when productId is invalid', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          productId: 0,
          detailState: const ProductDetailState(
            status: ProductDetailStatus.invalidId,
            errorMessage: 'Invalid product ID (0).',
            productId: 0,
          ),
        ),
      );

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('Invalid Product'), findsOneWidget);
    });

    testWidgets(
      'renders product details: title, brand, category, rating, price, discount, stock and specs',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            productId: 10,
            detailState: const ProductDetailState(
              status: ProductDetailStatus.loaded,
              product: tFullProduct,
              productId: 10,
            ),
          ),
        );
        await tester.pump();

        // 1. Title, Category, Brand
        expect(find.text('Gucci Bloom Eau de Parfum'), findsOneWidget);
        expect(find.text('FRAGRANCES'), findsOneWidget);
        expect(find.text('Gucci'), findsOneWidget);

        // 2. Rating & Review Count
        expect(find.text('4.8'), findsOneWidget);
        expect(find.text('(2 reviews)'), findsOneWidget);

        // 3. Stock Status
        expect(find.text('Only 4 left'), findsOneWidget);

        // 4. Prices ($135.00 effective, $150.00 original, -10% badge)
        expect(find.text('\$135.00'), findsOneWidget);
        expect(find.text('\$150.00'), findsOneWidget);
        expect(find.text('-10%'), findsOneWidget);

        // 5. Description
        expect(
          find.text('Capturing the spirit of contemporary and diverse women.'),
          findsOneWidget,
        );

        // 6. Specifications & Policies Card
        expect(find.text('Specifications & Policies'), findsOneWidget);
        expect(find.text('SKU'), findsOneWidget);
        expect(find.text('GC-BLOOM-100'), findsOneWidget);
        expect(find.text('Warranty'), findsOneWidget);
        expect(find.text('1 year limited warranty'), findsOneWidget);
        expect(find.text('Shipping'), findsOneWidget);
        expect(find.text('Free express shipping'), findsOneWidget);
        expect(find.text('Return Policy'), findsOneWidget);
        expect(find.text('30 days hassle-free return'), findsOneWidget);
        expect(find.text('10.0 × 15.0 × 5.0 cm'), findsOneWidget);
        expect(find.text('250.0g'), findsOneWidget);

        // 7. Reviews Section
        expect(find.text('Customer Reviews (2)'), findsOneWidget);
        expect(find.text('Sophia Miller'), findsOneWidget);
        expect(
          find.text('Absolutely intoxicating floral scent!'),
          findsOneWidget,
        );
        expect(find.text('Emma Watson'), findsOneWidget);
        expect(find.text('Long lasting and elegant.'), findsOneWidget);
      },
    );

    testWidgets('renders empty reviews notice when product has no reviews', (
      tester,
    ) async {
      const productNoReviews = Product(
        id: 11,
        title: 'Simple Product',
        description: 'No reviews here',
        category: 'groceries',
        price: 5.0,
        rating: 0.0,
        stock: 10,
        thumbnail: '',
        reviews: [],
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          productId: 11,
          detailState: const ProductDetailState(
            status: ProductDetailStatus.loaded,
            product: productNoReviews,
            productId: 11,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Customer Reviews (0)'), findsOneWidget);
      expect(find.text('No reviews yet'), findsOneWidget);
    });

    testWidgets(
      'gallery renders fallback when images and thumbnail are empty',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ProductImageGallery(
                images: [],
                thumbnail: '',
                productTitle: 'Empty Image Product',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
        expect(find.text('No product images available'), findsOneWidget);
      },
    );

    testWidgets('app bar includes back button with proper tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          productId: 10,
          detailState: const ProductDetailState(
            status: ProductDetailStatus.loaded,
            product: tFullProduct,
            productId: 10,
          ),
        ),
      );
      await tester.pump();

      expect(find.byTooltip('Back'), findsOneWidget);
    });
  });
}
