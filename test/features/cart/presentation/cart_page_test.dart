import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/widgets/app_empty_view.dart';
import 'package:shopsphere/core/widgets/app_loading_indicator.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/presentation/controllers/cart_notifier.dart';
import 'package:shopsphere/features/cart/presentation/controllers/cart_state.dart';
import 'package:shopsphere/features/cart/presentation/pages/cart_page.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:shopsphere/features/cart/presentation/widgets/order_summary_card.dart';

class FakeCartNotifier extends CartNotifier {
  final CartState initialState;
  bool incrementCalled = false;
  bool decrementCalled = false;
  bool removeCalled = false;
  bool clearCalled = false;
  bool checkoutCalled = false;

  FakeCartNotifier(this.initialState);

  @override
  CartState build() => initialState;

  @override
  Future<void> loadCart() async {}

  @override
  Future<void> incrementQuantity(int productId) async {
    incrementCalled = true;
  }

  @override
  Future<void> decrementQuantity(int productId) async {
    decrementCalled = true;
  }

  @override
  Future<void> removeItem(int productId) async {
    removeCalled = true;
  }

  @override
  Future<void> clearCart() async {
    clearCalled = true;
  }

  @override
  Future<bool> checkout({int? userId}) async {
    checkoutCalled = true;
    return true;
  }
}

void main() {
  const tItem = CartItem(
    productId: 1,
    title: 'Wireless Earbuds',
    price: 49.99,
    discountPercentage: 20.0,
    thumbnail: '',
    stock: 5,
    quantity: 2,
  );

  Widget createWidgetUnderTest({
    required CartState cartState,
    FakeCartNotifier? fakeNotifier,
  }) {
    final notifier = fakeNotifier ?? FakeCartNotifier(cartState);

    return ProviderScope(
      overrides: [cartNotifierProvider.overrideWith(() => notifier)],
      child: MaterialApp(theme: AppTheme.lightTheme, home: const CartPage()),
    );
  }

  group('CartPage Widget Tests', () {
    testWidgets(
      'renders loading indicator when status is loading and cart is empty',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            cartState: const CartState(status: CartStatus.loading),
          ),
        );

        expect(find.byType(AppLoadingIndicator), findsOneWidget);
        expect(find.text('Loading cart...'), findsOneWidget);
      },
    );

    testWidgets(
      'renders empty cart view with explore action when cart is empty',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            cartState: const CartState(
              status: CartStatus.ready,
              cart: Cart(items: []),
            ),
          ),
        );

        expect(find.byType(AppEmptyView), findsOneWidget);
        expect(find.text('Your cart is empty'), findsOneWidget);
        expect(find.text('Explore Products'), findsOneWidget);
      },
    );

    testWidgets('renders item cards and order summary when cart has items', (
      tester,
    ) async {
      final state = CartState(
        status: CartStatus.ready,
        cart: const Cart(items: [tItem]),
      );

      await tester.pumpWidget(createWidgetUnderTest(cartState: state));
      await tester.pump();

      expect(find.byType(CartItemCard), findsOneWidget);
      expect(find.text('Wireless Earbuds'), findsOneWidget);
      expect(find.text('\$39.99'), findsOneWidget); // Effective unit price
      expect(find.text('\$79.98'), findsWidgets); // Line total & Grand total
      expect(find.byType(OrderSummaryCard), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Place Order (Simulated)'), findsOneWidget);
    });

    testWidgets('tapping increment and decrement buttons calls notifier', (
      tester,
    ) async {
      final fake = FakeCartNotifier(
        CartState(
          status: CartStatus.ready,
          cart: const Cart(items: [tItem]),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(cartState: fake.initialState, fakeNotifier: fake),
      );
      await tester.pump();

      // Tap Increment
      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pump();
      expect(fake.incrementCalled, isTrue);

      // Tap Decrement
      await tester.tap(find.byTooltip('Decrease quantity'));
      await tester.pump();
      expect(fake.decrementCalled, isTrue);
    });

    testWidgets('clear cart action opens confirmation dialog', (tester) async {
      final fake = FakeCartNotifier(
        CartState(
          status: CartStatus.ready,
          cart: const Cart(items: [tItem]),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(cartState: fake.initialState, fakeNotifier: fake),
      );
      await tester.pump();

      // Tap Clear Cart icon in AppBar
      await tester.tap(find.byTooltip('Clear Cart'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Cart?'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to remove all items from your shopping cart?',
        ),
        findsOneWidget,
      );

      // Tap "Clear Cart" inside dialog
      await tester.tap(find.widgetWithText(FilledButton, 'Clear Cart'));
      await tester.pumpAndSettle();

      expect(fake.clearCalled, isTrue);
    });

    testWidgets('checkout button triggers checkout on notifier', (
      tester,
    ) async {
      final fake = FakeCartNotifier(
        CartState(
          status: CartStatus.ready,
          cart: const Cart(items: [tItem]),
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(cartState: fake.initialState, fakeNotifier: fake),
      );
      await tester.pump();

      await tester.tap(find.text('Place Order (Simulated)'));
      await tester.pump();

      expect(fake.checkoutCalled, isTrue);
    });

    testWidgets('renders wide two-column layout on wide screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final state = CartState(
        status: CartStatus.ready,
        cart: const Cart(items: [tItem]),
      );

      await tester.pumpWidget(createWidgetUnderTest(cartState: state));
      await tester.pump();

      expect(find.byType(CartItemCard), findsOneWidget);
      expect(find.byType(OrderSummaryCard), findsOneWidget);
    });
  });
}
