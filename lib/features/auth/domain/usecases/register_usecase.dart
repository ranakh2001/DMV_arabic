import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  const RegisterUsecase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call({
    required String name,
    required String contact,
    required int stateId,
    required String password,
  }) =>
      _repo.register(name: name, contact: contact, stateId: stateId, password: password);
}
