import 'package:flutter/material.dart';

/// A location pin that pops in with an elastic scale, used to mark states
/// on the onboarding page 3 map.
class OnboardingAnimatedPin extends StatelessWidget {
  const OnboardingAnimatedPin({
    super.key,
    required this.x,
    required this.y,
    required this.delay,
    required this.controller,
    required this.color,
  });

  final double x;
  final double y;
  final double delay;
  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, (delay + 0.35).clamp(0.0, 1.0), curve: Curves.elasticOut),
    );

    return Positioned(
      left: x - 10,
      top: y - 22,
      child: ScaleTransition(
        scale: anim,
        alignment: Alignment.bottomCenter,
        child: Icon(
          Icons.location_on_rounded,
          color: color,
          size: 22,
          shadows: [Shadow(color: color.withAlpha(120), blurRadius: 8)],
        ),
      ),
    );
  }
}
