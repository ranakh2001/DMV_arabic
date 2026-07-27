import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUsecase {
  const RefreshTokenUsecase(this._repo);
  final AuthRepository _repo;

  /// Returns the new access-token expiry on success.
  Future<Result<DateTime>> call() => _repo.refreshToken();
}
