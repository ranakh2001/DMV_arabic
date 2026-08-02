import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Small pill (icon + label) orbiting onboarding page 1's steering-wheel
/// hero.
class OnboardingFloatingBadge extends StatelessWidget {
  const OnboardingFloatingBadge({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withAlpha(130), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(55),
            blurRadius: 14,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
