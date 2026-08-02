import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../network/api_response.dart';

/// Registers this device's FCM token with the backend
/// (`PUT /users/fcm-token`), so it can receive push notifications.
class FcmTokenRemoteDataSource {
  const FcmTokenRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> register(String token) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        ApiConstants.fcmToken,
        data: {'fcm_token': token},
      );
      final json = response.data ?? {};
      final parsed = ApiResponse<dynamic>.fromJson(json, (data) => data);
      if (!parsed.success) {
        throw ServerException(messageAr: parsed.userMessage);
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map<String, dynamic>
          ? body['message'] as String?
          : null;
      throw ServerException(
        messageAr: message ?? 'تعذر تسجيل جهاز الإشعارات.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
