import '../../../../core/error/result.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case that removes an item from the cart.
class RemoveFromCartUseCase {
  final CartRepository _repository;

  const RemoveFromCartUseCase(this._repository);

  Future<Result<Cart>> call(int productId) =>
      _repository.removeFromCart(productId);
}
