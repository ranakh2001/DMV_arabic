import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response.dart';
import '../models/user_profile_model.dart';

/// Performs raw HTTP calls for the current user's profile using [Dio].
/// Throws [ServerException] on API errors; calling layer maps to [Failure].
class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserProfileModel> getProfile() async {
    final response = await _request(
      () => _dio.get<Map<String, dynamic>>(ApiConstants.profile),
    );
    return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfileModel> updateProfile(Map<String, dynamic> fields) async {
    final response = await _request(
      () => _dio.put<Map<String, dynamic>>(ApiConstants.profile, data: fields),
    );
    return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Uploads a new profile photo. Unlike the other `/users/*` endpoints,
  /// this one nests the updated user under `data.user` (`data` itself only
  /// holds `profile_photo_url` + `user`), so it's unwrapped here rather
  /// than reusing `UserProfileModel.fromJson(response.data)` directly.
  Future<UserProfileModel> uploadProfilePhoto(File photo) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        photo.path,
        filename: photo.uri.pathSegments.last,
      ),
    });
    final response = await _request(
      () => _dio.post<Map<String, dynamic>>(
        ApiConstants.profilePhoto,
        data: formData,
        options: Options(
          sendTimeout: const Duration(milliseconds: ApiConstants.uploadSendTimeoutMs),
          receiveTimeout: const Duration(
            milliseconds: ApiConstants.uploadReceiveTimeoutMs,
          ),
        ),
      ),
    );
    final data = response.data as Map<String, dynamic>;
    return UserProfileModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _request(
      () => _dio.put<Map<String, dynamic>>(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      ),
    );
  }

  /// Soft-deletes the account server-side (`account_status` -> disabled,
  /// email/phone/name anonymized). No request body required.
  Future<void> deleteAccount() async {
    await _request(
      () => _dio.delete<Map<String, dynamic>>(ApiConstants.deleteAccount),
    );
  }

  Future<ApiResponse<dynamic>> _request(
    Future<Response<Map<String, dynamic>>> Function() call,
  ) async {
    try {
      final response = await call();
      final json = response.data ?? {};
      final parsed = ApiResponse<dynamic>.fromJson(json, (data) => data);
      if (!parsed.success) {
        throw ServerException(messageAr: parsed.userMessage);
      }
      return parsed;
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map<String, dynamic>
          ? body['message'] as String?
          : null;
      throw ServerException(
        messageAr: message ?? 'حدث خطأ. يرجى المحاولة مرة أخرى.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
