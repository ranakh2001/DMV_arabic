import '../../../../core/utils/result.dart';
import '../entities/subscription_package.dart';

abstract interface class SubscriptionRepository {
  Future<Result<List<SubscriptionPackage>>> getSubscriptionPackages();
}
