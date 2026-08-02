import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class VerifyResetCodeUsecase {
  const VerifyResetCodeUsecase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call({required String contact, required String code}) =>
      _repo.verifyResetCode(contact: contact, code: code);
}
