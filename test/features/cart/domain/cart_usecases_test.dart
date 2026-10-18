import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_result.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/checkout_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:shopsphere/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  group('Cart Domain UseCases Tests', () {
    late MockCartRepository mockRepository;

    const tProduct = Product(
      id: 1,
      title: 'Perfume',
      description: 'A floral perfume',
      category: 'fragrances',
      price: 50.0,
      rating: 4.5,
      stock: 10,
      thumbnail: '',
    );

    setUp(() {
      mockRepository = MockCartRepository();
    });

    test('GetCartUseCase delegates to repository.getCart()', () async {
      when(
        () => mockRepository.getCart(),
      ).thenAnswer((_) async => const Result.success(Cart()));

      final useCase = GetCartUseCase(mockRepository);
      final result = await useCase();

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.getCart()).called(1);
    });

    test('AddToCartUseCase delegates to repository.addToCart()', () async {
      when(
        () => mockRepository.addToCart(tProduct, 2),
      ).thenAnswer((_) async => const Result.success(Cart()));

      final useCase = AddToCartUseCase(mockRepository);
      final result = await useCase(tProduct, quantity: 2);

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.addToCart(tProduct, 2)).called(1);
    });

    test(
      'UpdateCartItemQuantityUseCase delegates to repository.updateQuantity()',
      () async {
        when(
          () => mockRepository.updateQuantity(1, 3),
        ).thenAnswer((_) async => const Result.success(Cart()));

        final useCase = UpdateCartItemQuantityUseCase(mockRepository);
        final result = await useCase(1, 3);

        expect(result.isSuccess, isTrue);
        verify(() => mockRepository.updateQuantity(1, 3)).called(1);
      },
    );

    test(
      'RemoveFromCartUseCase delegates to repository.removeFromCart()',
      () async {
        when(
          () => mockRepository.removeFromCart(1),
        ).thenAnswer((_) async => const Result.success(Cart()));

        final useCase = RemoveFromCartUseCase(mockRepository);
        final result = await useCase(1);

        expect(result.isSuccess, isTrue);
        verify(() => mockRepository.removeFromCart(1)).called(1);
      },
    );

    test('ClearCartUseCase delegates to repository.clearCart()', () async {
      when(
        () => mockRepository.clearCart(),
      ).thenAnswer((_) async => const Result.success(Cart()));

      final useCase = ClearCartUseCase(mockRepository);
      final result = await useCase();

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.clearCart()).called(1);
    });

    test('CheckoutUseCase delegates to repository.checkout()', () async {
      when(() => mockRepository.checkout(42)).thenAnswer(
        (_) async => Result.success(
          CheckoutResult(
            id: 1,
            total: 100.0,
            discountedTotal: 90.0,
            totalProducts: 1,
            totalQuantity: 2,
            userId: 42,
          ),
        ),
      );

      final useCase = CheckoutUseCase(mockRepository);
      final result = await useCase(userId: 42);

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.checkout(42)).called(1);
    });
  });
}
