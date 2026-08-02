import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// A single check-marked bullet row, used for the "User Conduct" rules
/// list inside a [LegalSectionCard].
class LegalChecklistItem extends StatelessWidget {
  const LegalChecklistItem({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.sp(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: context.sp(18),
            color: context.appSuccess,
          ),
          SizedBox(width: context.sp(10)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(14),
                color: context.appTextSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
