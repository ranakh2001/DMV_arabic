import '../../../../core/utils/result.dart';
import '../entities/subscription_initiate.dart';
import '../repositories/payment_repository.dart';

class InitiateSubscriptionUsecase {
  const InitiateSubscriptionUsecase(this._repository);

  final PaymentRepository _repository;

  Future<Result<SubscriptionInitiate>> call({
    required int packageId,
    required String platform,
  }) => _repository.initiateSubscription(
    packageId: packageId,
    platform: platform,
  );
}
