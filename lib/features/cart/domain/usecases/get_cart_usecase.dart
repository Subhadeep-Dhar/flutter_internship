import '../../../../core/error/result.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

/// Use case that loads the user's active shopping cart.
class GetCartUseCase {
  final CartRepository _repository;

  const GetCartUseCase(this._repository);

  Future<Result<Cart>> call() => _repository.getCart();
}
