import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_result.dart';
import 'package:shopsphere/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/checkout_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:shopsphere/features/cart/presentation/controllers/cart_state.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}

class MockUpdateCartItemQuantityUseCase extends Mock
    implements UpdateCartItemQuantityUseCase {}

class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

class MockCheckoutUseCase extends Mock implements CheckoutUseCase {}

void main() {
  group('CartNotifier Tests', () {
    late MockGetCartUseCase mockGetCart;
    late MockAddToCartUseCase mockAddToCart;
    late MockUpdateCartItemQuantityUseCase mockUpdateQuantity;
    late MockRemoveFromCartUseCase mockRemoveFromCart;
    late MockClearCartUseCase mockClearCart;
    late MockCheckoutUseCase mockCheckout;

    const tProduct = Product(
      id: 1,
      title: 'Mascara',
      description: 'Lash mascara',
      category: 'beauty',
      price: 10.0,
      discountPercentage: 20.0,
      rating: 4.8,
      stock: 3,
      thumbnail: '',
    );

    final tItem = CartItem.fromProduct(tProduct, quantity: 1);
    final tCart = Cart(items: [tItem]);

    setUp(() {
      mockGetCart = MockGetCartUseCase();
      mockAddToCart = MockAddToCartUseCase();
      mockUpdateQuantity = MockUpdateCartItemQuantityUseCase();
      mockRemoveFromCart = MockRemoveFromCartUseCase();
      mockClearCart = MockClearCartUseCase();
      mockCheckout = MockCheckoutUseCase();

      when(
        () => mockGetCart(),
      ).thenAnswer((_) async => const Result.success(Cart()));
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          getCartUseCaseProvider.overrideWithValue(mockGetCart),
          addToCartUseCaseProvider.overrideWithValue(mockAddToCart),
          updateCartItemQuantityUseCaseProvider.overrideWithValue(
            mockUpdateQuantity,
          ),
          removeFromCartUseCaseProvider.overrideWithValue(mockRemoveFromCart),
          clearCartUseCaseProvider.overrideWithValue(mockClearCart),
          checkoutUseCaseProvider.overrideWithValue(mockCheckout),
        ],
      );
    }

    test('loadCart loads stored cart and transitions to ready', () async {
      when(() => mockGetCart()).thenAnswer((_) async => Result.success(tCart));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.loadCart();

      final state = container.read(cartNotifierProvider);
      expect(state.status, CartStatus.ready);
      expect(state.cart.items.length, 1);
      expect(state.totalItems, 1);
    });

    test('addItem updates cart state on success', () async {
      when(() => mockAddToCart(tProduct, quantity: 2)).thenAnswer(
        (_) async => Result.success(Cart(items: [tItem.copyWith(quantity: 2)])),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartNotifierProvider.notifier);
      final success = await notifier.addItem(tProduct, quantity: 2);

      expect(success, isTrue);
      final state = container.read(cartNotifierProvider);
      expect(state.status, CartStatus.ready);
      expect(state.cart.items.first.quantity, 2);
    });

    test('addItem sets error message on failure', () async {
      when(() => mockAddToCart(tProduct, quantity: 5)).thenAnswer(
        (_) async => const Result.error(
          ValidationFailure(message: 'Maximum stock limit reached.'),
        ),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartNotifierProvider.notifier);
      final success = await notifier.addItem(tProduct, quantity: 5);

      expect(success, isFalse);
      final state = container.read(cartNotifierProvider);
      expect(state.errorMessage, 'Maximum stock limit reached.');
    });

    test('incrementQuantity warns if item is already at stock limit', () async {
      final maxedCart = Cart(items: [tItem.copyWith(quantity: 3, stock: 3)]);
      when(
        () => mockGetCart(),
      ).thenAnswer((_) async => Result.success(maxedCart));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.loadCart();

      await notifier.incrementQuantity(1);

      final state = container.read(cartNotifierProvider);
      expect(
        state.errorMessage,
        contains('Maximum available stock (3) reached'),
      );
      verifyNever(() => mockUpdateQuantity(any(), any()));
    });

    test('decrementQuantity removes item when current quantity is 1', () async {
      when(() => mockGetCart()).thenAnswer((_) async => Result.success(tCart));
      when(
        () => mockRemoveFromCart(1),
      ).thenAnswer((_) async => const Result.success(Cart(items: [])));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.loadCart();

      await notifier.decrementQuantity(1);

      verify(() => mockRemoveFromCart(1)).called(1);
    });

    test('clearCart empties cart in state', () async {
      when(
        () => mockClearCart(),
      ).thenAnswer((_) async => const Result.success(Cart(items: [])));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartNotifierProvider.notifier);
      await notifier.clearCart();

      final state = container.read(cartNotifierProvider);
      expect(state.cart.isEmpty, isTrue);
    });

    group('checkout', () {
      test('fails with error if cart is empty', () async {
        when(
          () => mockGetCart(),
        ).thenAnswer((_) async => const Result.success(Cart(items: [])));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(cartNotifierProvider.notifier);
        await notifier.loadCart();

        final success = await notifier.checkout();

        expect(success, isFalse);
        expect(
          container.read(cartNotifierProvider).errorMessage,
          contains('cart is empty'),
        );
      });

      test(
        'sets checkoutSuccess and resets cart on remote order success',
        () async {
          when(
            () => mockGetCart(),
          ).thenAnswer((_) async => Result.success(tCart));
          when(() => mockCheckout(userId: any(named: 'userId'))).thenAnswer(
            (_) async => Result.success(
              CheckoutResult(
                id: 77,
                total: 10.0,
                discountedTotal: 8.0,
                totalProducts: 1,
                totalQuantity: 1,
                userId: 1,
              ),
            ),
          );

          final container = createContainer();
          addTearDown(container.dispose);

          final notifier = container.read(cartNotifierProvider.notifier);
          await notifier.loadCart();

          final success = await notifier.checkout(userId: 1);

          expect(success, isTrue);
          final state = container.read(cartNotifierProvider);
          expect(state.status, CartStatus.checkoutSuccess);
          expect(state.isCheckoutSuccess, isTrue);
          expect(state.checkoutResult?.id, 77);
          expect(state.cart.isEmpty, isTrue);
        },
      );

      test(
        'preserves cart and surfaces error message on remote checkout failure',
        () async {
          when(
            () => mockGetCart(),
          ).thenAnswer((_) async => Result.success(tCart));
          when(() => mockCheckout(userId: any(named: 'userId'))).thenAnswer(
            (_) async => const Result.error(
              ServerFailure(message: 'Payment gateway timeout.'),
            ),
          );

          final container = createContainer();
          addTearDown(container.dispose);

          final notifier = container.read(cartNotifierProvider.notifier);
          await notifier.loadCart();

          final success = await notifier.checkout(userId: 1);

          expect(success, isFalse);
          final state = container.read(cartNotifierProvider);
          expect(state.status, CartStatus.ready);
          expect(state.errorMessage, 'Payment gateway timeout.');
          expect(state.cart.items.length, 1); // Cart remains intact!
        },
      );
    });
  });
}
