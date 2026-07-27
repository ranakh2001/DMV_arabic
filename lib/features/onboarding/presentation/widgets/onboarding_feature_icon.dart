import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Emoji-in-circle + label used in onboarding page 2's feature row.
class OnboardingFeatureIcon extends StatelessWidget {
  const OnboardingFeatureIcon({super.key, required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withAlpha(25),
            border: Border.all(color: accent.withAlpha(80)),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontFamily: 'Almarai', fontSize: 13, color: context.appTextSecondary)),
      ],
    );
  }
}
