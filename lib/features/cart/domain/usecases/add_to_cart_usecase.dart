import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case that adds a product to the user's active shopping cart.
class AddToCartUseCase {
  final CartRepository _repository;

  const AddToCartUseCase(this._repository);

  Future<Result<Cart>> call(Product product, {int quantity = 1}) =>
      _repository.addToCart(product, quantity);
}
