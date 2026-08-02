import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'painters/starlight_painter.dart';

/// Looping twinkling-star overlay shown behind every onboarding page.
class OnboardingStarfield extends StatefulWidget {
  const OnboardingStarfield({super.key});

  @override
  State<OnboardingStarfield> createState() => _OnboardingStarfieldState();
}

class _OnboardingStarfieldState extends State<OnboardingStarfield>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.appPrimary;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        painter: StarlightPainter(progress: _ctrl.value, color: color),
      ),
    );
  }
}
