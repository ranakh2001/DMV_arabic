import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Raw HTTP calls for the Apple In-App Purchase checkout flow (iOS only).
/// Mirrors `PaymentRemoteDataSource`'s pattern for the Stripe flow.
class AppleIapRemoteDataSource {
  const AppleIapRemoteDataSource(this._dio);

  final Dio _dio;

  /// Opaque token used as `applicationUserName` on the StoreKit purchase, so
  /// the backend can tie the App Store transaction back to this account.
  Future<String> getAccountToken() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.subscriptionAppleAccountToken,
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر بدء عملية الشراء.',
        );
      }
      final data = json['data'] as Map<String, dynamic>? ?? {};
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw const ServerException(messageAr: 'تعذر بدء عملية الشراء.');
      }
      return token;
    } on DioException catch (e) {
      throw _dioToServer(
        e,
        fallback: 'تعذر بدء عملية الشراء. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  /// Asks the backend to validate the App Store transaction before it's
  /// treated as real.
  Future<void> verifyPurchase({
    required String transactionId,
    required String productId,
    required String receiptData,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.subscriptionVerify,
        data: {
          'transaction_id': transactionId,
          'product_id': productId,
          'receipt_data': receiptData,
          'platform': 'ios',
        },
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr:
              json['message'] as String? ?? 'تعذر التحقق من عملية الشراء.',
        );
      }
    } on DioException catch (e) {
      throw _dioToServer(
        e,
        fallback: 'تعذر التحقق من عملية الشراء. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  /// Records the verified purchase and activates the subscription.
  Future<void> submitPurchase({
    required String transactionId,
    required String productId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.subscriptionAppleIap,
        data: {'transaction_id': transactionId, 'product_id': productId},
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذرت عملية الشراء.',
        );
      }
    } on DioException catch (e) {
      throw _dioToServer(
        e,
        fallback: 'تعذرت عملية الشراء. يرجى المحاولة مرة أخرى.',
      );
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
