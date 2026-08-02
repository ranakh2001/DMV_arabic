import '../../../../core/utils/result.dart';
import '../entities/subscription_status.dart';
import '../repositories/payment_repository.dart';

class GetSubscriptionStatusUsecase {
  const GetSubscriptionStatusUsecase(this._repository);

  final PaymentRepository _repository;

  Future<Result<SubscriptionStatus>> call() =>
      _repository.getSubscriptionStatus();
}
