import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../widgets/score_path_card.dart';
import '../widgets/stat_info_card.dart';
import '../widgets/success_rate_card.dart';
import '../widgets/tab_screen_header.dart';

/// The "إحصائياتي" (My Stats) tab. Purely presentational for now — all
/// figures are static mock data until the backend/API is wired up.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const _passThreshold = 38 / 46;
  static const _scores = <double>[0.50, 0.55, 0.48, 0.85, 0.52, 0.58, 0.60, 0.90, 0.54, 0.62];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.isDesktop || context.isTablet ? 520 : double.infinity),
          child: ListView(
            padding: EdgeInsets.fromLTRB(context.sp(20), context.sp(16), context.sp(20), context.sp(24)),
            children: [
              TabScreenHeader(title: context.t('stats.title')),
              SizedBox(height: context.sp(20)),
              const SuccessRateCard(rate: 0.78, improvementPercent: 12),
              SizedBox(height: context.sp(16)),
              Row(
                children: [
                  Expanded(
                    child: StatInfoCard(
                      icon: Icons.replay_circle_filled_rounded,
                      label: context.t('stats.completed_simulations'),
                      value: '14',
                    ),
                  ),
                  SizedBox(width: context.sp(14)),
                  Expanded(
                    child: StatInfoCard(
                      icon: Icons.quiz_rounded,
                      label: context.t('stats.total_questions'),
                      value: context.ts('stats.total_questions_more', {'count': '250'}),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.sp(14)),
              Row(
                children: [
                  Expanded(
                    child: StatInfoCard(
                      icon: Icons.show_chart_rounded,
                      label: context.t('stats.average_score'),
                      value: '36.5',
                    ),
                  ),
                  SizedBox(width: context.sp(14)),
                  Expanded(
                    child: StatInfoCard(
                      icon: Icons.emoji_events_rounded,
                      label: context.t('stats.highest_score'),
                      value: '42/46',
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.sp(20)),
              const ScorePathCard(scores: _scores, passThreshold: _passThreshold),
            ],
          ),
        ),
      ),
    );
  }
}
