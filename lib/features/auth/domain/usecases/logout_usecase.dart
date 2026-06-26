import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class LogoutUsecase {
  const LogoutUsecase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call() => _repo.logout();
}
