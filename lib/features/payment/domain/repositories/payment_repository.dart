import '../../../../core/utils/result.dart';
import '../entities/subscription_history_entry.dart';
import '../entities/subscription_initiate.dart';
import '../entities/subscription_status.dart';

abstract interface class PaymentRepository {
  Future<Result<SubscriptionInitiate>> initiateSubscription({
    required int packageId,
    required String platform,
  });

  Future<Result<SubscriptionStatus>> getSubscriptionStatus();

  Future<Result<List<SubscriptionHistoryEntry>>> getSubscriptionHistory();
}
