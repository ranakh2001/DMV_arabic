import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../analytics/domain/entities/analytics_progress_entry.dart';
import '../../../analytics/domain/entities/analytics_summary.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import '../../../../core/widgets/skeleton_card.dart';
import '../providers/home_tab_provider.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/score_path_card.dart';
import '../widgets/stat_info_card.dart';
import '../widgets/stats_empty_state.dart';
import '../widgets/success_rate_card.dart';
import '../widgets/tab_screen_header.dart';

/// The "إحصائياتي" (My Stats) tab. Backed by `GET /analytics/summary`,
/// `GET /analytics/progress` and `GET /analytics/by-category`. Shows an
/// empty-state prompt until the user has completed at least one simulation.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isDesktop || context.isTablet
                ? 520
                : double.infinity,
          ),
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                context.sp(20),
                context.sp(16),
                context.sp(20),
                context.sp(24),
              ),
              children: [
                TabScreenHeader(title: context.t('stats.title')),
                SizedBox(height: context.sp(20)),
                ...summaryAsync.when(
                  data: (summary) => summary.totalSimulations == 0
                      ? [
                          StatsEmptyState(
                            onStartTap: () => ref
                                .read(homeTabProvider.notifier)
                                .select(HomeTab.simulation),
                          ),
                        ]
                      : [
                          _ScoreOverviewSection(summary: summary),
                          SizedBox(height: context.sp(16)),
                          const _CategoryBreakdownSection(),
                        ],
                  loading: () => [
                    const SkeletonCard(height: 160),
                    SizedBox(height: context.sp(16)),
                    const SkeletonCardList(count: 2, height: 76),
                  ],
                  error: (error, _) => [
                    _StatsLoadError(
                      onRetry: () => ref.invalidate(analyticsSummaryProvider),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(analyticsSummaryProvider.future),
      ref.refresh(analyticsProgressProvider.future),
      ref.refresh(analyticsByCategoryProvider.future),
    ]);
  }
}

/// Success-rate ring, the 2x2 stat grid, and the score-path chart. The
/// latter two need per-attempt history, so this watches
/// [analyticsProgressProvider] independently of the parent's summary fetch.
class _ScoreOverviewSection extends ConsumerWidget {
  const _ScoreOverviewSection({required this.summary});

  final AnalyticsSummary summary;

  static const _passThreshold =
      AppConstants.examMinPassCount / AppConstants.examQuestionCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(analyticsProgressProvider);
    final entries =
        progressAsync.valueOrNull ?? const <AnalyticsProgressEntry>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SuccessRateCard(
          rate: (summary.correctRatio / 100).clamp(0.0, 1.0),
          improvementPercent: _improvementPercent(entries),
        ),
        SizedBox(height: context.sp(16)),
        Row(
          children: [
            Expanded(
              child: StatInfoCard(
                icon: Icons.fact_check_rounded,
                label: context.t('stats.completed_simulations'),
                value: '${summary.totalSimulations}',
              ),
            ),
            SizedBox(width: context.sp(14)),
            Expanded(
              child: StatInfoCard(
                icon: Icons.quiz_rounded,
                label: context.t('stats.total_questions'),
                value: '${summary.totalAnswers}',
              ),
            ),
          ],
        ),
        SizedBox(height: context.sp(14)),
        Row(
          children: [
            Expanded(
              child: StatInfoCard(
                icon: Icons.insights_rounded,
                label: context.t('stats.average_score'),
                value: '${summary.averageScore.round()}%',
              ),
            ),
            SizedBox(width: context.sp(14)),
            Expanded(
              child: StatInfoCard(
                icon: Icons.emoji_events_rounded,
                label: context.t('stats.highest_score'),
                value: '${summary.highestScore.round()}%',
              ),
            ),
          ],
        ),
        SizedBox(height: context.sp(16)),
        progressAsync.when(
          data: (data) => data.isEmpty
              ? const SizedBox.shrink()
              : ScorePathCard(
                  scores: [
                    for (final e in data) (e.score / 100).clamp(0.0, 1.0),
                  ],
                  passThreshold: _passThreshold,
                ),
          loading: () => const SkeletonCard(height: 140),
          error: (error, _) => _InlineLoadError(
            onRetry: () => ref.invalidate(analyticsProgressProvider),
          ),
        ),
      ],
    );
  }

  /// Latest score vs. the average of every attempt before it, rounded and
  /// floored at zero (the surrounding UI copy always reads "Improved X%").
  int _improvementPercent(List<AnalyticsProgressEntry> entries) {
    if (entries.length < 2) return 0;
    final sorted = [...entries]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final latest = sorted.last.score;
    final previous = sorted.sublist(0, sorted.length - 1);
    final previousAverage =
        previous.map((e) => e.score).reduce((a, b) => a + b) / previous.length;
    return (latest - previousAverage).round().clamp(0, 100);
  }
}

/// Per-category accuracy breakdown; self-contained so a failure here doesn't
/// block the rest of the tab.
class _CategoryBreakdownSection extends ConsumerWidget {
  const _CategoryBreakdownSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(analyticsByCategoryProvider);

    return categoryAsync.when(
      data: (categories) => categories.isEmpty
          ? const SizedBox.shrink()
          : CategoryBreakdownCard(categories: categories),
      loading: () => const SkeletonCard(height: 160),
      error: (error, _) => _InlineLoadError(
        onRetry: () => ref.invalidate(analyticsByCategoryProvider),
      ),
    );
  }
}

class _StatsLoadError extends StatelessWidget {
  const _StatsLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(60)),
      child: Column(
        children: [
          Text(
            context.t('stats.load_error'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(14),
              color: context.appTextSecondary,
            ),
          ),
          SizedBox(height: context.sp(12)),
          TextButton(
            onPressed: onRetry,
            child: Text(context.t('common.retry')),
          ),
        ],
      ),
    );
  }
}

class _InlineLoadError extends StatelessWidget {
  const _InlineLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(16)),
      child: Column(
        children: [
          Text(
            context.t('stats.load_error'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(13),
              color: context.appTextSecondary,
            ),
          ),
          SizedBox(height: context.sp(8)),
          TextButton(
            onPressed: onRetry,
            child: Text(context.t('common.retry')),
          ),
        ],
      ),
    );
  }
}
