import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/subscription_history_entry.dart';
import '../../domain/entities/subscription_initiate.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl({required PaymentRemoteDataSource remote})
    : _remote = remote;

  final PaymentRemoteDataSource _remote;

  @override
  Future<Result<SubscriptionInitiate>> initiateSubscription({
    required int packageId,
    required String platform,
  }) async {
    try {
      final model = await _remote.initiateSubscription(
        packageId: packageId,
        platform: platform,
      );
      return Result.success(model.toEntity());
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

  @override
  Future<Result<SubscriptionStatus>> getSubscriptionStatus() async {
    try {
      final model = await _remote.getSubscriptionStatus();
      return Result.success(model.toEntity());
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

  @override
  Future<Result<List<SubscriptionHistoryEntry>>>
  getSubscriptionHistory() async {
    try {
      final models = await _remote.getSubscriptionHistory();
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
