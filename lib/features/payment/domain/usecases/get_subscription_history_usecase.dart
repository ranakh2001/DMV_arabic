import '../../../../core/utils/result.dart';
import '../entities/subscription_history_entry.dart';
import '../repositories/payment_repository.dart';

class GetSubscriptionHistoryUsecase {
  const GetSubscriptionHistoryUsecase(this._repository);

  final PaymentRepository _repository;

  Future<Result<List<SubscriptionHistoryEntry>>> call() =>
      _repository.getSubscriptionHistory();
}
