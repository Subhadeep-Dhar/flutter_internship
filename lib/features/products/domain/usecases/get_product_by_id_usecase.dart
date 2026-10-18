import '../../../../core/error/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Pure Dart use case to fetch a single product by its unique [id].
class GetProductByIdUseCase {
  final ProductRepository _repository;

  const GetProductByIdUseCase(this._repository);

  Future<Result<Product>> call(int id) {
    return _repository.getProductById(id);
  }
}
