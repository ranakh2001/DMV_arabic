import '../../../../core/utils/result.dart';
import '../entities/analytics_progress_entry.dart';
import '../repositories/analytics_repository.dart';

class GetAnalyticsProgressUsecase {
  const GetAnalyticsProgressUsecase(this._repo);
  final AnalyticsRepository _repo;

  Future<Result<List<AnalyticsProgressEntry>>> call() => _repo.getProgress();
}
