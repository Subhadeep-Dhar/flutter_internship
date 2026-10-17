import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case to restore and validate a stored session on application launch.
class RestoreSessionUseCase {
  final AuthRepository _repository;

  const RestoreSessionUseCase(this._repository);

  Future<Result<User>> call() {
    return _repository.restoreSession();
  }
}
