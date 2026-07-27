import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Shown on the stats tab in place of the stat cards until the user has
/// completed at least one simulation.
class StatsEmptyState extends StatelessWidget {
  const StatsEmptyState({super.key, required this.onStartTap});

  final VoidCallback onStartTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 22,
      padding: EdgeInsets.symmetric(vertical: context.sp(36), horizontal: context.sp(24)),
      child: Column(
        children: [
          Container(
            width: context.sp(64),
            height: context.sp(64),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.appPrimary.withAlpha(30),
            ),
            child: Icon(Icons.bar_chart_rounded, color: context.appPrimary, size: context.sp(30)),
          ),
          SizedBox(height: context.sp(18)),
          Text(
            context.t('stats.empty_message'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(14),
              color: context.appTextSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: context.sp(20)),
          ElevatedButton(
            onPressed: onStartTap,
            child: Text(context.t('simulation.start')),
          ),
        ],
      ),
    );
  }
}
