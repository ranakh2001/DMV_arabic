import '../../../../core/utils/result.dart';
import '../repositories/profile_repository.dart';

class ChangePasswordUsecase {
  const ChangePasswordUsecase(this._repo);
  final ProfileRepository _repo;

  Future<Result<void>> call({
    required String currentPassword,
    required String newPassword,
  }) =>
      _repo.changePassword(currentPassword: currentPassword, newPassword: newPassword);
}
