import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUsecase {
  const GetProfileUsecase(this._repo);
  final ProfileRepository _repo;

  Future<Result<UserProfile>> call() => _repo.getProfile();
}
