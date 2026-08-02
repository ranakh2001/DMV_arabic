import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Four-segment strength bar + label, driven by a 0-4 [strength] score.
/// Renders nothing until the user starts typing (strength 0).
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.strength});

  final int strength;

  @override
  Widget build(BuildContext context) {
    if (strength == 0) return const SizedBox.shrink();
    final color = _color(context);

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: context.sp(2)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: i < strength
                        ? color
                        : context.appTextDisabled.withAlpha(60),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(width: context.sp(8)),
        Text(
          _label(context),
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(12),
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _color(BuildContext context) {
    switch (strength) {
      case 1:
        return context.appError;
      case 2:
        return context.appSecondary;
      case 3:
        return context.appPrimary;
      case 4:
        return context.appSuccess;
      default:
        return Colors.transparent;
    }
  }

  String _label(BuildContext context) {
    switch (strength) {
      case 1:
        return context.t('password.strength.weak');
      case 2:
        return context.t('password.strength.fair');
      case 3:
        return context.t('password.strength.good');
      case 4:
        return context.t('password.strength.strong');
      default:
        return '';
    }
  }
}
