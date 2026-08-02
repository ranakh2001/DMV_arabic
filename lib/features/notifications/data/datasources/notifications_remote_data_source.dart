import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/notification_model.dart';

/// Performs the raw HTTP call for the (Bearer-auth) paginated
/// `/notifications` list.
class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.notifications,
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر جلب الإشعارات.',
        );
      }
      final page = json['data'] as Map<String, dynamic>? ?? {};
      final list = page['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map<String, dynamic>
          ? body['message'] as String?
          : null;
      throw ServerException(
        messageAr: message ?? 'تعذر جلب الإشعارات. يرجى المحاولة مرة أخرى.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
