import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Greeting + overall-progress glass card at the top of the home screen.
class WelcomeProgressCard extends StatelessWidget {
  const WelcomeProgressCard({
    super.key,
    required this.userName,
    required this.progress,
  });

  final String userName;

  /// 0.0–1.0
  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return GlassContainer(
      padding: EdgeInsets.all(context.sp(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.ts('home.greeting', {'name': userName}),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(20),
              fontWeight: FontWeight.w800,
              color: context.appTextPrimary,
            ),
          ),
          SizedBox(height: context.sp(6)),
          Text(
            context.t('home.subtitle'),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(14),
              color: context.appTextSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: context.sp(18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('home.progress_label'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w600,
                  color: context.appTextSecondary,
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w700,
                  color: context.appPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(8)),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: context.sp(9),
              backgroundColor: context.appTextDisabled.withAlpha(60),
              valueColor: AlwaysStoppedAnimation(context.appPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
