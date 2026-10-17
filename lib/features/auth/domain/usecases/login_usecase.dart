import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case to authenticate a user with credentials.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Result<User>> call({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username, password: password);
  }
}
