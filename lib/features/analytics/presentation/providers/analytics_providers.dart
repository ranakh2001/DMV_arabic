import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../data/datasources/analytics_remote_data_source.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/analytics_progress_entry.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/category_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/usecases/get_analytics_by_category_usecase.dart';
import '../../domain/usecases/get_analytics_progress_usecase.dart';
import '../../domain/usecases/get_analytics_summary_usecase.dart';

final analyticsRemoteDataSourceProvider = Provider<AnalyticsRemoteDataSource>(
  (ref) => AnalyticsRemoteDataSource(ref.watch(dioProvider)),
);

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepositoryImpl(
    remote: ref.watch(analyticsRemoteDataSourceProvider),
  ),
);

final getAnalyticsSummaryUsecaseProvider = Provider(
  (ref) => GetAnalyticsSummaryUsecase(ref.watch(analyticsRepositoryProvider)),
);

final getAnalyticsProgressUsecaseProvider = Provider(
  (ref) => GetAnalyticsProgressUsecase(ref.watch(analyticsRepositoryProvider)),
);

final getAnalyticsByCategoryUsecaseProvider = Provider(
  (ref) =>
      GetAnalyticsByCategoryUsecase(ref.watch(analyticsRepositoryProvider)),
);

/// Aggregate stats (completed simulations, average/highest score, overall
/// correct ratio) — drives the stats tab's empty-state gate and top cards.
final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final result = await ref.watch(getAnalyticsSummaryUsecaseProvider).call();
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );
});

/// The signed-in user's simulation scores over time, oldest first — feeds
/// the stats tab's score-path chart.
final analyticsProgressProvider = FutureProvider<List<AnalyticsProgressEntry>>((
  ref,
) async {
  final result = await ref.watch(getAnalyticsProgressUsecaseProvider).call();
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );
});

/// Answer accuracy broken down by question category — feeds the stats tab's
/// category breakdown card.
final analyticsByCategoryProvider = FutureProvider<List<CategoryAnalytics>>((
  ref,
) async {
  final result = await ref.watch(getAnalyticsByCategoryUsecaseProvider).call();
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );
});
