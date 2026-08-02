import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../data/datasources/subscription_remote_data_source.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/usecases/get_subscription_packages_usecase.dart';

final subscriptionRemoteDataSourceProvider =
    Provider<SubscriptionRemoteDataSource>(
      (ref) => SubscriptionRemoteDataSource(ref.watch(dioProvider)),
    );

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepositoryImpl(
    remote: ref.watch(subscriptionRemoteDataSourceProvider),
  ),
);

final getSubscriptionPackagesUsecaseProvider = Provider(
  (ref) =>
      GetSubscriptionPackagesUsecase(ref.watch(subscriptionRepositoryProvider)),
);

/// Backed by `GET /subscription-packages`. Watched by [SubscriptionPlansScreen].
final subscriptionPackagesProvider = FutureProvider<List<SubscriptionPackage>>((
  ref,
) async {
  final result = await ref.watch(getSubscriptionPackagesUsecaseProvider).call();
  return result.fold(
    onSuccess: (packages) => packages,
    onFailure: (failure) => throw failure,
  );
});
