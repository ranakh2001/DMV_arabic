import 'dart:io';

import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UploadProfilePhotoUsecase {
  const UploadProfilePhotoUsecase(this._repo);
  final ProfileRepository _repo;

  Future<Result<UserProfile>> call(File photo) => _repo.uploadProfilePhoto(photo);
}
