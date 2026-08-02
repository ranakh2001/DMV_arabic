import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Glass banner showing how many free trial questions remain, with a
/// progress bar tracking usage against the total free allowance.
class TrialUsageCard extends StatelessWidget {
  const TrialUsageCard({
    super.key,
    required this.remaining,
    required this.total,
    required this.progress,
  });

  final int remaining;
  final int total;

  /// 0.0–1.0
  final double progress;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 18,
      padding: EdgeInsets.all(context.sp(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: context.sp(38),
                height: context.sp(38),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appPrimary.withAlpha(30),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: context.appPrimary,
                  size: context.sp(20),
                ),
              ),
              SizedBox(width: context.sp(12)),
              Expanded(
                child: Text(
                  context.ts('subscription.trial_remaining', {
                    'remaining': '$remaining',
                    'total': '$total',
                  }),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w600,
                    color: context.appTextPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: context.sp(8),
              backgroundColor: context.appTextDisabled.withAlpha(60),
              valueColor: AlwaysStoppedAnimation(context.appPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
