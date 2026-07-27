import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Title + "View All" link row used above list-style sections.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;

  /// Trailing link (e.g. "View All"). Omit both this and [onActionTap] to
  /// render just the title, e.g. when there is nothing to view yet.
  final String? actionLabel;
  final VoidCallback? onActionTap;

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
        if (actionLabel != null)
          InkWell(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
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
