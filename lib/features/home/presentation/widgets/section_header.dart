import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Title + "View All" link row used above list-style sections.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(17),
            fontWeight: FontWeight.w700,
            color: context.appTextPrimary,
          ),
        ),
        InkWell(
          onTap: onActionTap,
          child: Text(
            actionLabel,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(13),
              fontWeight: FontWeight.w600,
              color: context.appPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
