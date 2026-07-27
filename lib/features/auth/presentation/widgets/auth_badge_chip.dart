import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Small pill label used across the auth flow (e.g. above a hero card's
/// title to name the current step).
class AuthBadgeChip extends StatelessWidget {
  const AuthBadgeChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: accent.withAlpha(30),
        border: Border.all(color: accent.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
    );
  }
}
