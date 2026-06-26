import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ResendCodeUsecase {
  const ResendCodeUsecase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call({required String contact}) =>
      _repo.resendCode(contact: contact);
}
