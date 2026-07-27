import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Circular icon button used for "back" navigation across the auth flow.
class CircleNavButton extends StatelessWidget {
  const CircleNavButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withAlpha(25),
          border: Border.all(color: accent.withAlpha(80), width: 1.2),
        ),
        child: Icon(icon, color: accent, size: 20),
      ),
    );
  }
}
