import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ResendVerificationCodeUsecase {
  const ResendVerificationCodeUsecase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call({required String contact}) =>
      _repo.resendVerificationCode(contact: contact);
}
