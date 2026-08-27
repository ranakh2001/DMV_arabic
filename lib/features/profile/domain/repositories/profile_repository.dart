import 'dart:io';

import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';

/// Abstract contract for profile operations. Implementations live in the data layer.
abstract interface class ProfileRepository {
  Future<Result<UserProfile>> getProfile();

  /// Updates only the fields present in [fields] (partial PUT body).
  Future<Result<UserProfile>> updateProfile(Map<String, dynamic> fields);

  Future<Result<UserProfile>> uploadProfilePhoto(File photo);

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Result<void>> deleteAccount();
}
