import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUsecase {
  const ForgotPasswordUsecase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call({required String contact}) =>
      _repo.forgotPassword(contact: contact);
}
