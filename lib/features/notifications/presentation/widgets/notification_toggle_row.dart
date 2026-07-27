import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// A glass-row switch: leading icon + label + toggle. Passing `null` for
/// [onChanged] renders it disabled (used when the master push toggle is off).
class NotificationToggleRow extends StatelessWidget {
  const NotificationToggleRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final textColor = enabled ? context.appTextPrimary : context.appTextSecondary.withAlpha(140);
    final iconColor = enabled ? context.appPrimary : context.appTextSecondary.withAlpha(140);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.appPrimary,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(width: context.sp(10)),
                Icon(icon, size: context.sp(20), color: iconColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
