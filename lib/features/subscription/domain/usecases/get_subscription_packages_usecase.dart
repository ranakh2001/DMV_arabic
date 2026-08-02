import '../../../../core/utils/result.dart';
import '../entities/subscription_package.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionPackagesUsecase {
  const GetSubscriptionPackagesUsecase(this._repo);
  final SubscriptionRepository _repo;

  Future<Result<List<SubscriptionPackage>>> call() =>
      _repo.getSubscriptionPackages();
}
