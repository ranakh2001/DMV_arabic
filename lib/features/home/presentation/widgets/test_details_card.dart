import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Glass card listing the simulation test's parameters: question count,
/// minimum passing score, and time allowed.
class TestDetailsCard extends StatelessWidget {
  const TestDetailsCard({
    super.key,
    required this.questionCount,
    required this.minPassCount,
  });

  final int questionCount;
  final int minPassCount;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, color: context.appPrimary, size: context.sp(20)),
              SizedBox(width: context.sp(8)),
              Text(
                context.t('simulation.details_title'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(16)),
          _TestDetailRow(
            icon: Icons.help_outline_rounded,
            label: context.t('simulation.question_count_label'),
            value: context.ts('simulation.question_count_value', {'count': '$questionCount'}),
            valueColor: context.appTextPrimary,
          ),
          SizedBox(height: context.sp(12)),
          _TestDetailRow(
            icon: Icons.check_circle_outline_rounded,
            label: context.t('simulation.min_pass_label'),
            value: context.ts('simulation.min_pass_value', {'count': '$minPassCount'}),
            valueColor: context.appSuccess,
          ),
          SizedBox(height: context.sp(12)),
          _TestDetailRow(
            icon: Icons.all_inclusive_rounded,
            label: context.t('simulation.time_label'),
            value: context.t('simulation.time_value'),
            valueColor: context.appSecondary,
          ),
        ],
      ),
    );
  }
}

class _TestDetailRow extends StatelessWidget {
  const _TestDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: context.sp(16), color: context.appTextSecondary),
            SizedBox(width: context.sp(6)),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(14),
                color: context.appTextSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.sp(12), vertical: context.sp(6)),
          decoration: BoxDecoration(
            color: valueColor.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: valueColor.withAlpha(90)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(13),
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
