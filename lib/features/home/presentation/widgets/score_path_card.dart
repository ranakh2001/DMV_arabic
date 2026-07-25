import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Glass card charting the last N simulation scores as a bar chart, with a
/// dashed line marking the passing threshold. Bars at/above the threshold
/// are highlighted in the primary color; the rest are muted.
class ScorePathCard extends StatelessWidget {
  const ScorePathCard({
    super.key,
    required this.scores,
    required this.passThreshold,
  });

  /// Chronological (oldest → newest), each 0.0–1.0.
  final List<double> scores;

  /// 0.0–1.0
  final double passThreshold;

  static const _chartHeight = 130.0;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('stats.score_path_title'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),
              Text(
                context.t('stats.last_10_attempts'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(12),
                  color: context.appTextSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(18)),
          SizedBox(
            height: context.sp(_chartHeight),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: context.sp(_chartHeight) * (1 - passThreshold),
                  child: _DashedLine(color: context.appSuccess),
                ),
                Positioned(
                  left: 0,
                  top: context.sp(_chartHeight) * (1 - passThreshold) - context.sp(16),
                  child: Text(
                    context.t('stats.pass_threshold'),
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w600,
                      color: context.appSuccess,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final score in scores)
                        _Bar(
                          heightFactor: score,
                          maxHeight: context.sp(_chartHeight),
                          highlighted: score >= passThreshold,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.sp(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('stats.first_attempt'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(11),
                  color: context.appTextDisabled,
                ),
              ),
              Text(
                context.t('stats.last_attempt'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(11),
                  color: context.appTextDisabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.heightFactor,
    required this.maxHeight,
    required this.highlighted,
  });

  final double heightFactor;
  final double maxHeight;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sp(16),
      height: maxHeight * heightFactor.clamp(0.05, 1.0),
      decoration: BoxDecoration(
        color: highlighted ? context.appPrimary : context.appTextDisabled.withAlpha(90),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 5.0;
          const dashGap = 4.0;
          final count = (constraints.maxWidth / (dashWidth + dashGap)).floor();
          return Row(
            children: List.generate(
              count,
              (_) => Padding(
                padding: const EdgeInsets.only(right: dashGap),
                child: Container(width: dashWidth, height: 1.4, color: color.withAlpha(180)),
              ),
            ),
          );
        },
      ),
    );
  }
}
