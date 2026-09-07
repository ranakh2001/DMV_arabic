import '../../../../core/utils/result.dart';
import '../repositories/apple_iap_repository.dart';

class VerifyApplePurchaseUsecase {
  const VerifyApplePurchaseUsecase(this._repository);

  final AppleIapRepository _repository;

  Future<Result<void>> call({
    required String transactionId,
    required String productId,
    required String receiptData,
  }) => _repository.verifyPurchase(
    transactionId: transactionId,
    productId: productId,
    receiptData: receiptData,
  );
}
