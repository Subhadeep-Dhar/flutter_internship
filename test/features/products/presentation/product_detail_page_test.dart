import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/widgets/app_empty_view.dart';
import 'package:shopsphere/core/widgets/app_error_view.dart';
import 'package:shopsphere/core/widgets/app_loading_indicator.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/presentation/controllers/cart_notifier.dart';
import 'package:shopsphere/features/cart/presentation/controllers/cart_state.dart';
import 'package:shopsphere/features/cart/presentation/widgets/add_to_cart_section.dart';
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

class FakeCartNotifier extends CartNotifier {
  final CartState? _initialState;
  Product? addedProduct;
  int? addedQuantity;

  FakeCartNotifier([this._initialState]);

  @override
  CartState build() =>
      _initialState ?? const CartState(status: CartStatus.ready);

  void setCart(Cart cart) {
    state = state.copyWith(cart: cart);
  }

  @override
  Future<void> loadCart() async {}

  @override
  Future<bool> addItem(Product product, {int quantity = 1}) async {
    addedProduct = product;
    addedQuantity = quantity;
    return true;
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
    FakeCartNotifier? fakeCartNotifier,
  }) {
    final notifier =
        fakeNotifier ?? FakeProductDetailNotifier(productId, detailState);
    final cartNotifier = fakeCartNotifier ?? FakeCartNotifier();

    return ProviderScope(
      overrides: [
        productDetailNotifierProvider(productId).overrideWith(() => notifier),
        cartNotifierProvider.overrideWith(() => cartNotifier),
        cartItemCountProvider.overrideWithValue(0),
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
      'renders Product Not Found view with Back to Catalogue action when status is notFound',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            productId: 9999,
            detailState: const ProductDetailState(
              status: ProductDetailStatus.notFound,
              errorMessage:
                  'The requested product does not exist or has been removed.',
              productId: 9999,
            ),
          ),
        );

        expect(find.byType(AppEmptyView), findsOneWidget);
        expect(find.text('Product Not Found'), findsOneWidget);
        expect(
          find.text(
            'The requested product does not exist or has been removed.',
          ),
          findsOneWidget,
        );
        expect(find.text('Back to Catalogue'), findsOneWidget);
      },
    );

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

    testWidgets(
      'renders AddToCartSection with quantity stepper and price calculation',
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

        expect(find.byType(AddToCartSection), findsOneWidget);
        expect(find.text('Quantity'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        // tFullProduct price = $150.00 with 10% discount -> $135.00
        expect(find.text('Add to Cart  •  \$135.00'), findsOneWidget);
      },
    );

    testWidgets(
      'stepper increment and decrement updates selected quantity and total',
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

        // Tap + button
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
        expect(find.text('Add to Cart  •  \$270.00'), findsOneWidget);

        // Tap - button
        await tester.tap(find.byIcon(Icons.remove_rounded));
        await tester.pump();

        expect(find.text('1'), findsOneWidget);
        expect(find.text('Add to Cart  •  \$135.00'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Add to Cart triggers addItem on CartNotifier and shows snackbar',
      (tester) async {
        final fakeCartNotifier = FakeCartNotifier();

        await tester.pumpWidget(
          createWidgetUnderTest(
            productId: 10,
            detailState: const ProductDetailState(
              status: ProductDetailStatus.loaded,
              product: tFullProduct,
              productId: 10,
            ),
            fakeCartNotifier: fakeCartNotifier,
          ),
        );
        await tester.pump();

        // Tap + to select quantity 2
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();

        // Tap Add to Cart button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(fakeCartNotifier.addedProduct?.id, 10);
        expect(fakeCartNotifier.addedQuantity, 2);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('Added 2 × "${tFullProduct.title}" to cart'),
          findsOneWidget,
        );
        expect(find.text('VIEW CART'), findsOneWidget);
      },
    );

    testWidgets('disables Add to Cart button when product is out of stock', (
      tester,
    ) async {
      const outOfStockProduct = Product(
        id: 10,
        title: 'Gucci Bloom Eau de Parfum',
        description: 'Capturing the spirit of contemporary and diverse women.',
        category: 'fragrances',
        price: 150.0,
        rating: 4.85,
        stock: 0,
        thumbnail: 'https://thumb.jpg',
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          productId: 10,
          detailState: ProductDetailState(
            status: ProductDetailStatus.loaded,
            product: outOfStockProduct,
            productId: 10,
          ),
        ),
      );
      await tester.pump();

      expect(
        find.widgetWithText(ElevatedButton, 'Out of Stock'),
        findsOneWidget,
      );
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets(
      'displays inline message and disables button labelled "Cart Full" when cart is at capacity',
      (tester) async {
        final fullCart = Cart(
          items: [
            const CartItem(
              productId: 999,
              title: 'Bulk Cart Items',
              price: 10.0,
              thumbnail: '',
              stock: 100,
              quantity: 99,
            ),
          ],
        );
        final fakeCartNotifier = FakeCartNotifier(
          CartState(status: CartStatus.ready, cart: fullCart),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productId: 10,
            detailState: const ProductDetailState(
              status: ProductDetailStatus.loaded,
              product: tFullProduct,
              productId: 10,
            ),
            fakeCartNotifier: fakeCartNotifier,
          ),
        );
        await tester.pump();

        // 1. Visible inline message near controls without opening cart
        expect(
          find.byKey(const Key('cart_full_inline_message')),
          findsOneWidget,
        );
        expect(
          find.text(
            'Your cart is full. Remove an item or reduce quantities to add more.',
          ),
          findsOneWidget,
        );
        // SnackBar must not be shown
        expect(find.byType(SnackBar), findsNothing);

        // 2. Add to Cart button is disabled and labelled "Cart Full"
        expect(
          find.widgetWithText(ElevatedButton, 'Cart Full'),
          findsOneWidget,
        );
        final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(btn.onPressed, isNull);

        // Max additional is 0
        expect(find.text('Max additional: 0'), findsOneWidget);
      },
    );

    testWidgets(
      're-enables Add to Cart button reactively when cart capacity is freed without reloading page',
      (tester) async {
        final fullCart = Cart(
          items: [
            const CartItem(
              productId: 999,
              title: 'Bulk Cart Items',
              price: 10.0,
              thumbnail: '',
              stock: 100,
              quantity: 99,
            ),
          ],
        );
        final fakeCartNotifier = FakeCartNotifier(
          CartState(status: CartStatus.ready, cart: fullCart),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productId: 10,
            detailState: const ProductDetailState(
              status: ProductDetailStatus.loaded,
              product: tFullProduct,
              productId: 10,
            ),
            fakeCartNotifier: fakeCartNotifier,
          ),
        );
        await tester.pump();

        expect(find.text('Cart Full'), findsOneWidget);
        expect(
          find.byKey(const Key('cart_full_inline_message')),
          findsOneWidget,
        );

        // User removes an item or reduces quantity in the background / cart page
        fakeCartNotifier.setCart(const Cart(items: []));
        await tester.pump();

        // Reactively updates: banner disappears, button re-enabled with price
        expect(find.byKey(const Key('cart_full_inline_message')), findsNothing);
        expect(find.text('Cart Full'), findsNothing);
        expect(find.text('Add to Cart  •  \$135.00'), findsOneWidget);

        final updatedBtn = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(updatedBtn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'displays available stock, selected quantity, and max additional quantity correctly',
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

        expect(find.text('Available stock: 4 units'), findsOneWidget);
        expect(find.text('Max additional: 4'), findsOneWidget);
        expect(find.text('Selected: 1'), findsOneWidget);
      },
    );

    testWidgets(
      'product already in cart uses remaining stock and prevents incrementing beyond limit',
      (tester) async {
        // Product has stock 4, 2 already in cart
        final existingItem = CartItem.fromProduct(tFullProduct, quantity: 2);
        final cartWith2 = Cart(items: [existingItem]);
        final fakeCartNotifier = FakeCartNotifier(
          CartState(status: CartStatus.ready, cart: cartWith2),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productId: 10,
            detailState: const ProductDetailState(
              status: ProductDetailStatus.loaded,
              product: tFullProduct,
              productId: 10,
            ),
            fakeCartNotifier: fakeCartNotifier,
          ),
        );
        await tester.pump();

        expect(find.text('Available stock: 4 units'), findsOneWidget);
        expect(find.text('(2 in cart)'), findsOneWidget);
        expect(find.text('Max additional: 2'), findsOneWidget);

        // Tap increment once -> selected becomes 2
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
        expect(find.text('Selected: 2'), findsOneWidget);
        expect(find.text('Add to Cart  •  \$270.00'), findsOneWidget);

        // Tap increment again -> cannot increment beyond remaining stock 2
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
        expect(find.text('Selected: 2'), findsOneWidget);
      },
    );

    testWidgets(
      'maximum additional quantity respects cart-wide capacity when smaller than stock',
      (tester) async {
        const productWithLargeStock = Product(
          id: 10,
          title: 'Gucci Bloom Eau de Parfum',
          description: 'Contemporary scent.',
          category: 'fragrances',
          price: 150.0,
          rating: 4.85,
          stock: 50,
          thumbnail: 'https://thumb.jpg',
        );

        // Cart has 96 items across other products -> remaining cart capacity is 3
        final otherItem = const CartItem(
          productId: 888,
          title: 'Existing Item',
          price: 10.0,
          thumbnail: '',
          stock: 100,
          quantity: 96,
        );
        final cartWith96 = Cart(items: [otherItem]);
        final fakeCartNotifier = FakeCartNotifier(
          CartState(status: CartStatus.ready, cart: cartWith96),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productId: 10,
            detailState: const ProductDetailState(
              status: ProductDetailStatus.loaded,
              product: productWithLargeStock,
              productId: 10,
            ),
            fakeCartNotifier: fakeCartNotifier,
          ),
        );
        await tester.pump();

        expect(find.text('Available stock: 50 units'), findsOneWidget);
        // Max additional capped at 3 due to cart capacity
        expect(find.text('Max additional: 3'), findsOneWidget);

        // Increment to 3
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();

        expect(find.text('3'), findsOneWidget);
        expect(find.text('Selected: 3'), findsOneWidget);

        // At upper limit, explanation for cart capacity is shown
        expect(
          find.textContaining('Cart capacity limit reached'),
          findsOneWidget,
        );

        // Tapping increment again does not increase beyond 3
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();
        expect(find.text('3'), findsOneWidget);
      },
    );

    testWidgets(
      'displays accurate "Stock Limit Reached" message when all product stock is in cart',
      (tester) async {
        // Product has stock 4, and user has all 4 in cart (cart total is 4, so not cart full)
        final itemWithAllStock = CartItem.fromProduct(
          tFullProduct,
          quantity: 4,
        );
        final cartWithMaxProduct = Cart(items: [itemWithAllStock]);
        final fakeCartNotifier = FakeCartNotifier(
          CartState(status: CartStatus.ready, cart: cartWithMaxProduct),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productId: 10,
            detailState: const ProductDetailState(
              status: ProductDetailStatus.loaded,
              product: tFullProduct,
              productId: 10,
            ),
            fakeCartNotifier: fakeCartNotifier,
          ),
        );
        await tester.pump();

        // Must display "Stock Limit Reached", NOT "Cart Full"
        expect(
          find.widgetWithText(ElevatedButton, 'Stock Limit Reached'),
          findsOneWidget,
        );
        expect(find.widgetWithText(ElevatedButton, 'Cart Full'), findsNothing);

        final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(btn.onPressed, isNull);

        expect(
          find.byKey(const Key('stock_limit_inline_message')),
          findsOneWidget,
        );
        expect(
          find.text('You already have all 4 available units in your cart.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays accurate out of stock inline message when product stock is 0 without labelling as Cart Full',
      (tester) async {
        const outOfStockProduct = Product(
          id: 10,
          title: 'Gucci Bloom Eau de Parfum',
          description: 'Contemporary fragrance.',
          category: 'fragrances',
          price: 150.0,
          rating: 4.85,
          stock: 0,
          thumbnail: 'https://thumb.jpg',
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            productId: 10,
            detailState: const ProductDetailState(
              status: ProductDetailStatus.loaded,
              product: outOfStockProduct,
              productId: 10,
            ),
          ),
        );
        await tester.pump();

        expect(
          find.byKey(const Key('out_of_stock_inline_message')),
          findsOneWidget,
        );
        expect(
          find.text('This product is currently out of stock.'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(ElevatedButton, 'Out of Stock'),
          findsOneWidget,
        );
        expect(find.widgetWithText(ElevatedButton, 'Cart Full'), findsNothing);
      },
    );
  });
}
