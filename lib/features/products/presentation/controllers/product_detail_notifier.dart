import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import 'product_detail_state.dart';

/// Riverpod 3 Family Notifier managing single product details retrieval,
/// loading states, and retryable error recovery.
class ProductDetailNotifier extends Notifier<ProductDetailState> {
  final int productId;
  final GetProductByIdUseCase? _injectedUseCase;
  int _activeRequestId = 0;

  ProductDetailNotifier(this.productId, {GetProductByIdUseCase? useCase})
    : _injectedUseCase = useCase;

  GetProductByIdUseCase get _useCase =>
      _injectedUseCase ?? ref.read(getProductByIdUseCaseProvider);

  @override
  ProductDetailState build() {
    if (productId <= 0) {
      return ProductDetailState(
        status: ProductDetailStatus.invalidId,
        errorMessage: 'Invalid product ID ($productId).',
        productId: productId,
      );
    }

    // Schedule asynchronous load if not already triggered
    Future.microtask(() {
      if (ref.mounted && _activeRequestId == 0) {
        loadProduct();
      }
    });

    return ProductDetailState(
      status: ProductDetailStatus.loading,
      productId: productId,
    );
  }

  /// Loads the product details for the current product ID with stale response protection.
  Future<void> loadProduct() async {
    if (!ref.mounted) return;

    if (productId <= 0) {
      state = state.copyWith(
        status: ProductDetailStatus.invalidId,
        errorMessage: () => 'Invalid product ID ($productId).',
      );
      return;
    }

    final requestId = ++_activeRequestId;

    state = state.copyWith(
      status: ProductDetailStatus.loading,
      errorMessage: () => null,
    );

    final result = await _useCase(productId);

    // Stale request guard: if another request was triggered, or provider disposed, discard this result
    if (!ref.mounted) return;
    if (requestId != _activeRequestId) return;

    result.when(
      success: (product) {
        if (!ref.mounted) return;
        state = state.copyWith(
          status: ProductDetailStatus.loaded,
          product: () => product,
          errorMessage: () => null,
        );
      },
      error: (failure) {
        if (!ref.mounted) return;
        state = state.copyWith(
          status: ProductDetailStatus.error,
          errorMessage: () => failure.message,
        );
      },
    );
  }

  /// Retries loading the current product.
  Future<void> retry() => loadProduct();
}
