import '../../../../core/utils/result.dart';
import '../entities/analytics_progress_entry.dart';
import '../entities/analytics_summary.dart';
import '../entities/category_analytics.dart';

abstract interface class AnalyticsRepository {
  Future<Result<AnalyticsSummary>> getSummary();

  Future<Result<List<AnalyticsProgressEntry>>> getProgress();

  Future<Result<List<CategoryAnalytics>>> getByCategory();
}
