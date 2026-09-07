import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/apple_iap_repository.dart';
import '../datasources/apple_iap_remote_data_source.dart';

class AppleIapRepositoryImpl implements AppleIapRepository {
  const AppleIapRepositoryImpl({required AppleIapRemoteDataSource remote})
    : _remote = remote;

  final AppleIapRemoteDataSource _remote;

  @override
  Future<Result<String>> getAccountToken() async {
    try {
      final token = await _remote.getAccountToken();
      return Result.success(token);
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
  Future<Result<void>> verifyPurchase({
    required String transactionId,
    required String productId,
    required String receiptData,
  }) async {
    try {
      await _remote.verifyPurchase(
        transactionId: transactionId,
        productId: productId,
        receiptData: receiptData,
      );
      return const Result.success(null);
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
  Future<Result<void>> submitPurchase({
    required String transactionId,
    required String productId,
  }) async {
    try {
      await _remote.submitPurchase(
        transactionId: transactionId,
        productId: productId,
      );
      return const Result.success(null);
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
