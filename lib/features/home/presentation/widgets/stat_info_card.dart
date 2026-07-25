import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Icon + label + bold value tile used in the stats grid (completed
/// simulations, total questions, average score, highest score).
class StatInfoCard extends StatelessWidget {
  const StatInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.appPrimary, size: context.sp(22)),
          SizedBox(height: context.sp(10)),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(18),
              fontWeight: FontWeight.w800,
              color: context.appTextPrimary,
            ),
          ),
          SizedBox(height: context.sp(4)),
          Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(12),
              color: context.appTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
