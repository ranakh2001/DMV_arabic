import '../../../../core/utils/result.dart';
import '../repositories/apple_iap_repository.dart';

class SubmitAppleIapPurchaseUsecase {
  const SubmitAppleIapPurchaseUsecase(this._repository);

  final AppleIapRepository _repository;

  Future<Result<void>> call({
    required String transactionId,
    required String productId,
  }) => _repository.submitPurchase(
    transactionId: transactionId,
    productId: productId,
  );
}
