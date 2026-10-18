import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';
import 'package:shopsphere/features/cart/data/models/cart_model.dart';
import 'package:shopsphere/features/cart/data/models/checkout_result_model.dart';
import 'package:shopsphere/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

void main() {
  group('CartRepositoryImpl Tests', () {
    late MockCartLocalDataSource mockLocalDataSource;
    late MockCartRemoteDataSource mockRemoteDataSource;
    late CartRepositoryImpl repository;

    const tProduct = Product(
      id: 10,
      title: 'Ergonomic Desk Chair',
      description: 'Comfortable mesh chair',
      category: 'furniture',
      price: 100.0,
      discountPercentage: 10.0,
      rating: 4.5,
      stock: 4,
      thumbnail: 'https://chair.jpg',
    );

    setUp(() {
      mockLocalDataSource = MockCartLocalDataSource();
      mockRemoteDataSource = MockCartRemoteDataSource();
      repository = CartRepositoryImpl(
        localDataSource: mockLocalDataSource,
        remoteDataSource: mockRemoteDataSource,
      );

      registerFallbackValue(const CartModel(items: []));
    });

    test('getCart retrieves cart successfully from local storage', () async {
      const item = CartItemModel(
        productId: 10,
        title: 'Chair',
        price: 90.0,
        thumbnail: '',
        quantity: 1,
      );
      when(
        () => mockLocalDataSource.getCart(),
      ).thenAnswer((_) async => const CartModel(items: [item]));

      final result = await repository.getCart();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.items.length, 1);
      expect(result.dataOrNull?.items.first.title, 'Chair');
    });

    group('addToCart', () {
      test('returns ValidationFailure if quantity is <= 0', () async {
        final result = await repository.addToCart(tProduct, 0);

        expect(result.isError, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
      });

      test('returns ValidationFailure if product is out of stock', () async {
        const outOfStockProduct = Product(
          id: 99,
          title: 'Sold Out Item',
          description: 'Sold out item description',
          category: 'furniture',
          price: 50.0,
          rating: 0.0,
          stock: 0,
          thumbnail: '',
        );

        final result = await repository.addToCart(outOfStockProduct, 1);

        expect(result.isError, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        expect(
          result.failureOrNull?.message,
          'This product is currently out of stock.',
        );
      });

      test(
        'adds new item and saves to local storage when not already present',
        () async {
          when(
            () => mockLocalDataSource.getCart(),
          ).thenAnswer((_) async => const CartModel(items: []));
          when(
            () => mockLocalDataSource.saveCart(any()),
          ).thenAnswer((_) async {});

          final result = await repository.addToCart(tProduct, 2);

          expect(result.isSuccess, isTrue);
          final cart = result.dataOrNull!;
          expect(cart.items.length, 1);
          expect(cart.items.first.productId, 10);
          expect(cart.items.first.quantity, 2);

          verify(() => mockLocalDataSource.saveCart(any())).called(1);
        },
      );

      test(
        'updates quantity and prevents duplicate items when product already in cart',
        () async {
          final existingItem = CartItemModel.fromEntity(
            CartItem.fromProduct(tProduct, quantity: 2),
          );
          when(
            () => mockLocalDataSource.getCart(),
          ).thenAnswer((_) async => CartModel(items: [existingItem]));
          when(
            () => mockLocalDataSource.saveCart(any()),
          ).thenAnswer((_) async {});

          final result = await repository.addToCart(tProduct, 1);

          expect(result.isSuccess, isTrue);
          final cart = result.dataOrNull!;
          expect(cart.items.length, 1); // No duplicates
          expect(cart.items.first.productId, 10);
          expect(cart.items.first.quantity, 3); // 2 + 1 = 3
        },
      );

      test(
        'returns ValidationFailure when attempting to add to an item already at max stock',
        () async {
          final maxedItem = CartItemModel.fromEntity(
            CartItem.fromProduct(tProduct, quantity: 4), // stock is 4
          );
          when(
            () => mockLocalDataSource.getCart(),
          ).thenAnswer((_) async => CartModel(items: [maxedItem]));

          final result = await repository.addToCart(tProduct, 1);

          expect(result.isError, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          expect(
            result.failureOrNull?.message,
            contains('maximum available stock'),
          );
          verifyNever(() => mockLocalDataSource.saveCart(any()));
        },
      );

      test(
        'returns ValidationFailure when cart has reached maximum capacity of 99 units',
        () async {
          final fullItem = CartItemModel(
            productId: 99,
            title: 'Bulk Item',
            price: 5.0,
            thumbnail: '',
            stock: 100,
            quantity: 99,
          );
          when(
            () => mockLocalDataSource.getCart(),
          ).thenAnswer((_) async => CartModel(items: [fullItem]));

          final result = await repository.addToCart(tProduct, 1);

          expect(result.isError, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          expect(
            result.failureOrNull?.message,
            contains(
              'Your cart is full. Remove an item or reduce quantities to add more.',
            ),
          );
          verifyNever(() => mockLocalDataSource.saveCart(any()));
        },
      );

      test(
        'returns ValidationFailure when requested quantity exceeds addable limit',
        () async {
          final existingItem = CartItemModel.fromEntity(
            CartItem.fromProduct(tProduct, quantity: 2), // stock is 4
          );
          when(
            () => mockLocalDataSource.getCart(),
          ).thenAnswer((_) async => CartModel(items: [existingItem]));

          // Remaining stock is 2, but requesting 3
          final result = await repository.addToCart(tProduct, 3);

          expect(result.isError, isTrue);
          expect(result.failureOrNull, isA<ValidationFailure>());
          expect(
            result.failureOrNull?.message,
            contains('Only 2 more can be added to your cart'),
          );
          verifyNever(() => mockLocalDataSource.saveCart(any()));
        },
      );
    });

    group('updateQuantity', () {
      test('updates item quantity and clamps to stock limit', () async {
        final item = CartItemModel.fromEntity(
          CartItem.fromProduct(tProduct, quantity: 1),
        );
        when(
          () => mockLocalDataSource.getCart(),
        ).thenAnswer((_) async => CartModel(items: [item]));
        when(
          () => mockLocalDataSource.saveCart(any()),
        ).thenAnswer((_) async {});

        // Try updating to 10 (exceeds stock 4)
        final result = await repository.updateQuantity(10, 10);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.items.first.quantity, 4); // Clamped to 4
      });

      test('removes item when quantity is updated to 0', () async {
        final item = CartItemModel.fromEntity(
          CartItem.fromProduct(tProduct, quantity: 2),
        );
        when(
          () => mockLocalDataSource.getCart(),
        ).thenAnswer((_) async => CartModel(items: [item]));
        when(
          () => mockLocalDataSource.saveCart(any()),
        ).thenAnswer((_) async {});

        final result = await repository.updateQuantity(10, 0);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.items, isEmpty);
      });

      test('returns NotFoundFailure when updating item not in cart', () async {
        when(
          () => mockLocalDataSource.getCart(),
        ).thenAnswer((_) async => const CartModel(items: []));

        final result = await repository.updateQuantity(999, 2);

        expect(result.isError, isTrue);
        expect(result.failureOrNull, isA<NotFoundFailure>());
      });
    });

    test('removeFromCart filters out target item', () async {
      final item1 = CartItemModel.fromEntity(
        CartItem.fromProduct(tProduct, quantity: 1),
      );
      const item2 = CartItemModel(
        productId: 20,
        title: 'Item 2',
        price: 10,
        thumbnail: '',
      );
      when(
        () => mockLocalDataSource.getCart(),
      ).thenAnswer((_) async => CartModel(items: [item1, item2]));
      when(() => mockLocalDataSource.saveCart(any())).thenAnswer((_) async {});

      final result = await repository.removeFromCart(10);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.items.length, 1);
      expect(result.dataOrNull?.items.first.productId, 20);
    });

    test('clearCart empties storage and returns empty cart', () async {
      when(() => mockLocalDataSource.clearCart()).thenAnswer((_) async {});

      final result = await repository.clearCart();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.isEmpty, isTrue);
      verify(() => mockLocalDataSource.clearCart()).called(1);
    });

    group('checkout', () {
      test('returns ValidationFailure if cart is empty', () async {
        when(
          () => mockLocalDataSource.getCart(),
        ).thenAnswer((_) async => const CartModel(items: []));

        final result = await repository.checkout(1);

        expect(result.isError, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        verifyNever(
          () => mockRemoteDataSource.checkout(
            userId: any(named: 'userId'),
            items: any(named: 'items'),
          ),
        );
      });

      test('submits order and clears local cart on remote success', () async {
        final item = CartItemModel.fromEntity(
          CartItem.fromProduct(tProduct, quantity: 2),
        );
        when(
          () => mockLocalDataSource.getCart(),
        ).thenAnswer((_) async => CartModel(items: [item]));
        when(
          () => mockRemoteDataSource.checkout(
            userId: 1,
            items: any(named: 'items'),
          ),
        ).thenAnswer(
          (_) async => CheckoutResultModel(
            id: 99,
            total: 200.0,
            discountedTotal: 180.0,
            totalProducts: 1,
            totalQuantity: 2,
            userId: 1,
          ),
        );
        when(() => mockLocalDataSource.clearCart()).thenAnswer((_) async {});

        final result = await repository.checkout(1);

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.id, 99);
        expect(result.dataOrNull?.discountedTotal, 180.0);
        verify(() => mockLocalDataSource.clearCart()).called(1);
      });

      test('preserves local cart when remote checkout fails', () async {
        final item = CartItemModel.fromEntity(
          CartItem.fromProduct(tProduct, quantity: 2),
        );
        when(
          () => mockLocalDataSource.getCart(),
        ).thenAnswer((_) async => CartModel(items: [item]));
        when(
          () => mockRemoteDataSource.checkout(
            userId: 1,
            items: any(named: 'items'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/carts/add'),
            type: DioExceptionType.connectionError,
          ),
        );

        final result = await repository.checkout(1);

        expect(result.isError, isTrue);
        expect(result.failureOrNull, isA<NetworkFailure>());
        // CRITICAL: Local cart must NOT be wiped if order submission failed!
        verifyNever(() => mockLocalDataSource.clearCart());
      });
    });
  });
}
