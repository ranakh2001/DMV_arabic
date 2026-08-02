import '../../../../core/utils/result.dart';
import '../entities/category_analytics.dart';
import '../repositories/analytics_repository.dart';

class GetAnalyticsByCategoryUsecase {
  const GetAnalyticsByCategoryUsecase(this._repo);
  final AnalyticsRepository _repo;

  Future<Result<List<CategoryAnalytics>>> call() => _repo.getByCategory();
}
