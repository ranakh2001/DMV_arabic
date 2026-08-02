import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/analytics_progress_entry.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/category_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl({required AnalyticsRemoteDataSource remote})
    : _remote = remote;

  final AnalyticsRemoteDataSource _remote;

  @override
  Future<Result<AnalyticsSummary>> getSummary() async {
    try {
      final model = await _remote.getSummary();
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(_toApiFailure(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<AnalyticsProgressEntry>>> getProgress() async {
    try {
      final models = await _remote.getProgress();
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(_toApiFailure(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<CategoryAnalytics>>> getByCategory() async {
    try {
      final models = await _remote.getByCategory();
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(_toApiFailure(e));
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  ApiFailure _toApiFailure(ServerException e) => ApiFailure(
    messageAr: e.messageAr,
    messageEn: e.messageEn,
    statusCode: e.statusCode,
    errorCode: e.errorCode,
  );
}
