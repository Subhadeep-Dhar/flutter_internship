import '../../../../core/error/result.dart';
import '../entities/category.dart';
import '../repositories/product_repository.dart';

/// Pure Dart use case to fetch catalogue product categories.
class GetCategoriesUseCase {
  final ProductRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<Result<List<Category>>> call() {
    return _repository.getCategories();
  }
}
