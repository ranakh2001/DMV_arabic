import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Header row for a question screen: "Question X of Y" on the leading side,
/// selected-state location chip on the trailing side.
class ExamTopBar extends StatelessWidget {
  const ExamTopBar({
    super.key,
    required this.current,
    required this.total,
    required this.stateName,
  });

  final int current;
  final int total;
  final String stateName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.ts('exam.question_progress', {'current': '$current', 'total': '$total'}),
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(14),
            fontWeight: FontWeight.w700,
            color: context.appTextPrimary,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.sp(12), vertical: context.sp(6)),
          decoration: BoxDecoration(
            color: context.appGlassTint,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: context.appGlassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded, size: context.sp(15), color: context.appPrimary),
              SizedBox(width: context.sp(4)),
              Text(
                stateName,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
