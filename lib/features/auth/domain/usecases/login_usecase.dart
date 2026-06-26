import '../../../../core/utils/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  const LoginUsecase(this._repo);
  final AuthRepository _repo;

  Future<Result<({AuthSession? session, String? unverifiedContact})>> call({
    required String contact,
    required String password,
  }) =>
      _repo.login(contact: contact, password: password);
}
