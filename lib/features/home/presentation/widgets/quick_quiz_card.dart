import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// "Quick test" glass card: title + subtitle + full-width start button.
class QuickQuizCard extends StatelessWidget {
  const QuickQuizCard({super.key, required this.onStart});

  final VoidCallback onStart;

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
                context.t('home.quick_test_card'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),
              Container(
                width: context.sp(38),
                height: context.sp(38),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appPrimary.withAlpha(30),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: context.appPrimary,
                  size: context.sp(20),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(4)),
          Text(
            context.t('home.quick_quiz_subtitle'),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(13),
              color: context.appTextSecondary,
            ),
          ),
          SizedBox(height: context.sp(16)),
          ElevatedButton(
            onPressed: onStart,
            child: Text(context.t('home.start')),
          ),
        ],
      ),
    );
  }
}
