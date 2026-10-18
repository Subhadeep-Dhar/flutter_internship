import '../../../../core/error/result.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case that modifies the quantity of an item in the cart.
class UpdateCartItemQuantityUseCase {
  final CartRepository _repository;

  const UpdateCartItemQuantityUseCase(this._repository);

  Future<Result<Cart>> call(int productId, int quantity) =>
      _repository.updateQuantity(productId, quantity);
}
