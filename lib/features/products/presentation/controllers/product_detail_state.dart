import '../../domain/entities/product.dart';

/// Status states for the product details screen.
enum ProductDetailStatus { initial, loading, loaded, error, invalidId }

/// Immutable state model representing a single product's detail view.
class ProductDetailState {
  final ProductDetailStatus status;
  final Product? product;
  final String? errorMessage;
  final int? productId;

  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.errorMessage,
    this.productId,
  });

  /// Factory for clean initial state.
  factory ProductDetailState.initial([int? id]) =>
      ProductDetailState(productId: id);

  bool get isInitial => status == ProductDetailStatus.initial;
  bool get isLoading => status == ProductDetailStatus.loading;
  bool get isLoaded => status == ProductDetailStatus.loaded;
  bool get isError => status == ProductDetailStatus.error;
  bool get isInvalidId => status == ProductDetailStatus.invalidId;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    Product? Function()? product,
    String? Function()? errorMessage,
    int? productId,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product != null ? product() : this.product,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      productId: productId ?? this.productId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductDetailState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          product == other.product &&
          errorMessage == other.errorMessage &&
          productId == other.productId;

  @override
  int get hashCode =>
      status.hashCode ^
      product.hashCode ^
      errorMessage.hashCode ^
      productId.hashCode;

  @override
  String toString() =>
      'ProductDetailState(status: $status, id: $productId, product: ${product?.title}, error: $errorMessage)';
}
