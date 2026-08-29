import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateSelectedStateUsecase {
  const UpdateSelectedStateUsecase(this._repo);
  final ProfileRepository _repo;

  Future<Result<UserProfile>> call(int stateId) =>
      _repo.updateSelectedState(stateId);
}
