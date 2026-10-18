import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/di/providers.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:shopsphere/features/products/presentation/controllers/product_detail_state.dart';

class MockGetProductByIdUseCase extends Mock implements GetProductByIdUseCase {}

void main() {
  group('ProductDetailNotifier', () {
    late MockGetProductByIdUseCase mockGetProductByIdUseCase;

    const tProduct = Product(
      id: 42,
      title: 'Ergonomic Desk Chair',
      description: 'Comfortable mesh office chair',
      category: 'furniture',
      price: 199.99,
      discountPercentage: 15.0,
      rating: 4.8,
      stock: 12,
      thumbnail: 'https://thumb.jpg',
      images: ['https://img1.jpg', 'https://img2.jpg'],
    );

    setUp(() {
      mockGetProductByIdUseCase = MockGetProductByIdUseCase();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          getProductByIdUseCaseProvider.overrideWithValue(
            mockGetProductByIdUseCase,
          ),
        ],
      );
    }

    test('build emits invalidId when product id is <= 0', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(productDetailNotifierProvider(0));
      expect(state.status, ProductDetailStatus.invalidId);
      expect(state.isInvalidId, isTrue);
      expect(state.errorMessage, contains('Invalid product ID'));
    });

    test(
      'loadProduct emits loaded with Product on successful response',
      () async {
        when(
          () => mockGetProductByIdUseCase(42),
        ).thenAnswer((_) async => const Result.success(tProduct));

        final container = createContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          productDetailNotifierProvider(42),
          (_, _) {},
        );
        addTearDown(subscription.close);

        final notifier = container.read(
          productDetailNotifierProvider(42).notifier,
        );
        await notifier.loadProduct();

        final state = container.read(productDetailNotifierProvider(42));
        expect(state.status, ProductDetailStatus.loaded);
        expect(state.isLoaded, isTrue);
        expect(state.product, tProduct);
        expect(state.errorMessage, isNull);

        verify(() => mockGetProductByIdUseCase(42)).called(1);
      },
    );

    test(
      'loadProduct emits error with failure message on network/server error',
      () async {
        when(() => mockGetProductByIdUseCase(42)).thenAnswer(
          (_) async => const Result.error(
            NetworkFailure(message: 'Connection timed out'),
          ),
        );

        final container = createContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          productDetailNotifierProvider(42),
          (_, _) {},
        );
        addTearDown(subscription.close);

        final notifier = container.read(
          productDetailNotifierProvider(42).notifier,
        );
        await notifier.loadProduct();

        final state = container.read(productDetailNotifierProvider(42));
        expect(state.status, ProductDetailStatus.error);
        expect(state.isError, isTrue);
        expect(state.errorMessage, 'Connection timed out');
        expect(state.product, isNull);
      },
    );

    test(
      'retry re-invokes loadProduct and recovers to loaded on success',
      () async {
        when(() => mockGetProductByIdUseCase(42)).thenAnswer(
          (_) async =>
              const Result.error(NetworkFailure(message: 'Offline error')),
        );

        final container = createContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          productDetailNotifierProvider(42),
          (_, _) {},
        );
        addTearDown(subscription.close);

        final notifier = container.read(
          productDetailNotifierProvider(42).notifier,
        );
        await notifier.loadProduct();
        expect(
          container.read(productDetailNotifierProvider(42)).status,
          ProductDetailStatus.error,
        );

        // Simulate network coming back
        when(
          () => mockGetProductByIdUseCase(42),
        ).thenAnswer((_) async => const Result.success(tProduct));

        await notifier.retry();

        final state = container.read(productDetailNotifierProvider(42));
        expect(state.status, ProductDetailStatus.loaded);
        expect(state.product, tProduct);
        expect(state.errorMessage, isNull);
      },
    );
  });
}
