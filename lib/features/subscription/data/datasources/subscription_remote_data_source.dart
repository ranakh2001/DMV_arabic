import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/subscription_package_model.dart';

/// Performs the raw HTTP call for the (Bearer-auth) `/subscription-packages`
/// list.
class SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<SubscriptionPackageModel>> getSubscriptionPackages() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.subscriptionPackages,
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر جلب باقات الاشتراك.',
        );
      }
      final list = json['data'] as List<dynamic>? ?? [];
      return list
          .map(
            (e) => SubscriptionPackageModel.fromJson(e as Map<String, dynamic>),
          )
          .where((m) => m.isActive)
          .toList();
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map<String, dynamic>
          ? body['message'] as String?
          : null;
      throw ServerException(
        messageAr:
            message ?? 'تعذر جلب باقات الاشتراك. يرجى المحاولة مرة أخرى.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
