import '../../../../core/utils/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class VerifyUsecase {
  const VerifyUsecase(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthSession>> call({
    required String contact,
    required String code,
  }) =>
      _repo.verify(contact: contact, code: code);
}
