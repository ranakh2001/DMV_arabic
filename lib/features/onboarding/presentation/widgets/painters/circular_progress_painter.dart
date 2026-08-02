import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ring progress indicator drawn on onboarding page 2's front card.
class CircularProgressPainter extends CustomPainter {
  const CircularProgressPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withAlpha(40)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter old) =>
      old.progress != progress || old.color != color;
}
