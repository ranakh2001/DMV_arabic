import '../../../../core/utils/result.dart';
import '../entities/analytics_summary.dart';
import '../repositories/analytics_repository.dart';

class GetAnalyticsSummaryUsecase {
  const GetAnalyticsSummaryUsecase(this._repo);
  final AnalyticsRepository _repo;

  Future<Result<AnalyticsSummary>> call() => _repo.getSummary();
}
