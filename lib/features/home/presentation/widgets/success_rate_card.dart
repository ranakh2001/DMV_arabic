import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import 'circular_progress_ring.dart';

/// Big glass card at the top of the stats tab: a large ring showing the
/// overall success rate, a trend chip, and an encouragement message.
class SuccessRateCard extends StatelessWidget {
  const SuccessRateCard({
    super.key,
    required this.rate,
    required this.improvementPercent,
  });

  /// 0.0–1.0
  final double rate;
  final int improvementPercent;

  @override
  Widget build(BuildContext context) {
    final percent = (rate * 100).round();

    return GlassContainer(
      radius: 22,
      padding: EdgeInsets.symmetric(
        vertical: context.sp(28),
        horizontal: context.sp(20),
      ),
      child: Column(
        children: [
          CircularProgressRing(
            value: rate,
            size: 160,
            strokeWidth: 12,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(30),
                    fontWeight: FontWeight.w800,
                    color: context.appTextPrimary,
                  ),
                ),
                Text(
                  context.t('stats.success_rate'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(12),
                    color: context.appTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.sp(18)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.sp(14),
              vertical: context.sp(7),
            ),
            decoration: BoxDecoration(
              color: context.appSuccess.withAlpha(30),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: context.appSuccess.withAlpha(110)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: context.appSuccess,
                  size: context.sp(16),
                ),
                SizedBox(width: context.sp(6)),
                Text(
                  context.ts('stats.improvement', {
                    'percent': '$improvementPercent',
                  }),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w700,
                    color: context.appSuccess,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.sp(14)),
          Text(
            context.t('stats.performance_message'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(14),
              color: context.appTextSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
