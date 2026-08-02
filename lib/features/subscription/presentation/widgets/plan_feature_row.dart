import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// A single "✓ feature" bullet line, reused for every entry in a
/// [PlanCard]'s feature list.
class PlanFeatureRow extends StatelessWidget {
  const PlanFeatureRow({super.key, required this.label, this.accentColor});

  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final tint = accentColor ?? context.appPrimary;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(6)),
      child: Row(
        children: [
          Container(
            width: context.sp(20),
            height: context.sp(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tint.withAlpha(35),
            ),
            child: Icon(Icons.check_rounded, size: context.sp(13), color: tint),
          ),
          SizedBox(width: context.sp(10)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(14),
                fontWeight: FontWeight.w500,
                color: context.appTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
