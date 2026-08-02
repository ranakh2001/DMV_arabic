import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl({
    required SubscriptionRemoteDataSource remote,
  }) : _remote = remote;

  final SubscriptionRemoteDataSource _remote;

  @override
  Future<Result<List<SubscriptionPackage>>> getSubscriptionPackages() async {
    try {
      final models = await _remote.getSubscriptionPackages();
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(
        ApiFailure(
          messageAr: e.messageAr,
          messageEn: e.messageEn,
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        ),
      );
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
