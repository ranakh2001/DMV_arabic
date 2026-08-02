import 'dart:io';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// Concrete implementation of [ProfileRepository].
/// Converts exceptions to [Result.failure] with localized [Failure] values.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required ProfileRemoteDataSource remote})
    : _remote = remote;

  final ProfileRemoteDataSource _remote;

  @override
  Future<Result<UserProfile>> getProfile() async {
    try {
      final model = await _remote.getProfile();
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(Map<String, dynamic> fields) async {
    try {
      final model = await _remote.updateProfile(fields);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<UserProfile>> uploadProfilePhoto(File photo) async {
    try {
      final model = await _remote.uploadProfilePhoto(photo);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPassword,
      );
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(_fromServer(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  ApiFailure _fromServer(ServerException e) => ApiFailure(
    messageAr: e.messageAr,
    messageEn: e.messageEn,
    statusCode: e.statusCode,
    errorCode: e.errorCode,
  );
}
