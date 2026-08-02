import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// The frosted card holding each onboarding page's title/subtitle (and any
/// extra content), pinned near the bottom of the page.
class OnboardingContentCard extends StatelessWidget {
  const OnboardingContentCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
        radius: 24,
        blur: 18,
        opacity: 0.85,
        tint: context.appSurface,
        border: accent.withAlpha(90),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(45),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accent.withAlpha(24),
            blurRadius: 24,
            spreadRadius: -6,
          ),
        ],
        child: child,
      ),
    );
  }
}
