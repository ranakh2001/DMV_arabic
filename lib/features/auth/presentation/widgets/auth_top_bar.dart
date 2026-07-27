import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'circle_nav_button.dart';

/// Header row shared by every screen in the forgot-password/verify flow:
/// a back button with a centered title.
class AuthTopBar extends StatelessWidget {
  const AuthTopBar({
    super.key,
    required this.title,
    required this.onBack,
    this.titleColor,
  });

  final String title;
  final VoidCallback onBack;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          CircleNavButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: titleColor ?? context.appTextPrimary,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
