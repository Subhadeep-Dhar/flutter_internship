import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Use case to sign out the user and clear cached tokens.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.logout();
  }
}
