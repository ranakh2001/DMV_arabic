import '../../../../core/utils/result.dart';
import '../repositories/profile_repository.dart';

class DeleteAccountUsecase {
  const DeleteAccountUsecase(this._repo);
  final ProfileRepository _repo;

  Future<Result<void>> call() => _repo.deleteAccount();
}
