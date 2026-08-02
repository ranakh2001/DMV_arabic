import 'package:flutter/material.dart';

/// Expanding, fading ring pulses drawn behind the onboarding page 1 hero.
class PulseRingPainter extends CustomPainter {
  const PulseRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final p = ((progress + i / 3.0) % 1.0);
      final radius = maxR * 0.35 + maxR * 0.65 * p;
      final opacity = (1 - p) * 0.35;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withAlpha((opacity * 255).round())
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(PulseRingPainter old) =>
      old.progress != progress || old.color != color;
}
