import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Small icon + text hint row. Reused for the simulation tab's auto-save
/// and review notes.
class InfoNoteRow extends StatelessWidget {
  const InfoNoteRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(6)),
      child: Row(
        children: [
          Icon(icon, size: context.sp(16), color: context.appTextSecondary),
          SizedBox(width: context.sp(8)),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(13),
                color: context.appTextSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
