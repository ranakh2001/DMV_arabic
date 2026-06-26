import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class BootstrapSessionUsecase {
  const BootstrapSessionUsecase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthUser?>> call() => _repo.bootstrapSession();
}
