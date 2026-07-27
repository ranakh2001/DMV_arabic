import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Simple steering-wheel glyph drawn for onboarding page 1's hero.
class SteeringWheelPainter extends CustomPainter {
  const SteeringWheelPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), r * 0.90, paint);
    canvas.drawCircle(Offset(cx, cy), r * 0.18, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), r * 0.18, paint..style = PaintingStyle.stroke);

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    for (int i = 0; i < 3; i++) {
      final angle = (90.0 + i * 120.0) * math.pi / 180.0;
      canvas.drawLine(
        Offset(cx + r * 0.18 * math.cos(angle), cy + r * 0.18 * math.sin(angle)),
        Offset(cx + r * 0.90 * math.cos(angle), cy + r * 0.90 * math.sin(angle)),
        paint,
      );
    }

    final wavePaint = Paint()
      ..color = color.withAlpha(160)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final startX = cx - 18 + i * 18.0;
      final startY = cy - r * 0.90 - 8;
      final path = Path()
        ..moveTo(startX, startY)
        ..cubicTo(startX - 6, startY - 8, startX + 6, startY - 16, startX, startY - 24);
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(SteeringWheelPainter old) => old.color != color;
}
