import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// A tappable settings row: leading icon + label + a leading-edge chevron
/// (">" in RTL reads as "into this row"). Reused for "Change Password",
/// "Privacy Policy" and "Contact Us".
class SettingsLinkTile extends StatelessWidget {
  const SettingsLinkTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.sp(14)),
        child: Row(
          children: [
            Icon(icon, size: context.sp(20), color: context.appPrimary),
            SizedBox(width: context.sp(12)),
            Expanded(
              child: Text(
                label,

                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.w600,
                  color: context.appTextPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: context.sp(20),
              color: context.appTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
