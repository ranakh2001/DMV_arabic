import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUsecase {
  const ResetPasswordUsecase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call({
    required String contact,
    required String code,
    required String newPassword,
  }) =>
      _repo.resetPassword(contact: contact, code: code, newPassword: newPassword);
}
