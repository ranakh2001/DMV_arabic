import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/subscription_history_entry_model.dart';
import '../models/subscription_initiate_model.dart';
import '../models/subscription_status_model.dart';

/// Raw HTTP calls for the Stripe checkout flow.
class PaymentRemoteDataSource {
  const PaymentRemoteDataSource(this._dio);

  final Dio _dio;

  Future<SubscriptionInitiateModel> initiateSubscription({
    required int packageId,
    required String platform,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.subscriptionInitiate,
        data: {'package_id': packageId, 'platform': platform},
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر بدء عملية الدفع.',
        );
      }
      return SubscriptionInitiateModel.fromJson(
        json['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _dioToServer(
        e,
        fallback: 'تعذر بدء عملية الدفع. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  Future<SubscriptionStatusModel> getSubscriptionStatus() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.subscriptionStatus,
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr:
              json['message'] as String? ?? 'تعذر التحقق من حالة الاشتراك.',
        );
      }
      return SubscriptionStatusModel.fromJson(
        json['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _dioToServer(e, fallback: 'تعذر التحقق من حالة الاشتراك.');
    }
  }

  Future<List<SubscriptionHistoryEntryModel>> getSubscriptionHistory() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.subscriptionHistory,
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر جلب سجل الاشتراكات.',
        );
      }
      final page = json['data'] as Map<String, dynamic>? ?? {};
      final list = page['data'] as List<dynamic>? ?? [];
      return list
          .map(
            (e) => SubscriptionHistoryEntryModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _dioToServer(e, fallback: 'تعذر جلب سجل الاشتراكات.');
    }
  }

  ServerException _dioToServer(DioException e, {required String fallback}) {
    final body = e.response?.data;
    final message = body is Map<String, dynamic>
        ? body['message'] as String?
        : null;
    return ServerException(
      messageAr: message ?? fallback,
      statusCode: e.response?.statusCode,
    );
  }
}
