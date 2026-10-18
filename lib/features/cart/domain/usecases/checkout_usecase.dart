import '../../../../core/error/result.dart';
import '../entities/checkout_result.dart';
import '../repositories/cart_repository.dart';

/// Use case that executes a simulated checkout order with DummyJSON.
class CheckoutUseCase {
  final CartRepository _repository;

  const CheckoutUseCase(this._repository);

  Future<Result<CheckoutResult>> call({int userId = 1}) =>
      _repository.checkout(userId);
}
