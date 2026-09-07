import '../../../../core/utils/result.dart';

abstract class AppleIapRepository {
  Future<Result<String>> getAccountToken();

  Future<Result<void>> verifyPurchase({
    required String transactionId,
    required String productId,
    required String receiptData,
  });

  Future<Result<void>> submitPurchase({
    required String transactionId,
    required String productId,
  });
}
