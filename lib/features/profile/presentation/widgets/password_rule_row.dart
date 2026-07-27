import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// A single password-rule checklist row: check icon + label, dimmed until
/// [isValid] is met. Repeats 4x on the Change Password screen.
class PasswordRuleRow extends StatelessWidget {
  const PasswordRuleRow({super.key, required this.label, required this.isValid});

  final String label;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final color = isValid ? context.appSuccess : context.appTextSecondary;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(3)),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: color,
            size: context.sp(18),
          ),
          SizedBox(width: context.sp(8)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontFamily: 'Almarai', fontSize: context.sp(13), color: color),
            ),
          ),
        ],
      ),
    );
  }
}
