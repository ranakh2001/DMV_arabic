import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUsecase {
  const UpdateProfileUsecase(this._repo);
  final ProfileRepository _repo;

  Future<Result<UserProfile>> call(Map<String, dynamic> fields) => _repo.updateProfile(fields);
}
