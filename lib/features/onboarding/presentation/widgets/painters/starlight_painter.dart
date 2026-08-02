import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Twinkling starfield + faint radiating lines drawn behind every
/// onboarding page.
class StarlightPainter extends CustomPainter {
  const StarlightPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  // (x%, y%, radius, twinklePhase)
  static const _stars = [
    (0.08, 0.06, 2.2, 0.00),
    (0.23, 0.13, 1.6, 0.28),
    (0.72, 0.09, 2.6, 0.55),
    (0.88, 0.18, 1.8, 0.10),
    (0.14, 0.38, 2.0, 0.72),
    (0.84, 0.32, 2.2, 0.42),
    (0.04, 0.58, 1.6, 0.65),
    (0.93, 0.52, 2.4, 0.20),
    (0.32, 0.78, 1.8, 0.88),
    (0.68, 0.74, 2.0, 0.50),
    (0.50, 0.11, 1.6, 0.15),
    (0.42, 0.90, 2.0, 0.62),
    (0.78, 0.65, 1.6, 0.33),
    (0.11, 0.84, 2.2, 0.47),
    (0.36, 0.25, 1.8, 0.05),
    (0.96, 0.78, 2.0, 0.38),
    (0.60, 0.44, 1.4, 0.78),
    (0.55, 0.60, 1.4, 0.90),
  ];

  // (x1%, y1%, x2%, y2%)  — long diagonal lines radiating from edges
  static const _lines = [
    (0.00, 0.00, 0.58, 0.36),
    (0.00, 0.04, 0.42, 0.52),
    (1.00, 0.00, 0.43, 0.40),
    (1.00, 0.07, 0.62, 0.48),
    (0.00, 0.38, 0.36, 0.18),
    (0.00, 0.56, 0.28, 0.76),
    (1.00, 0.35, 0.64, 0.16),
    (1.00, 0.60, 0.68, 0.82),
    (0.10, 1.00, 0.44, 0.66),
    (0.90, 1.00, 0.56, 0.63),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = color.withAlpha(28)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    for (final l in _lines) {
      canvas.drawLine(
        Offset(l.$1 * w, l.$2 * h),
        Offset(l.$3 * w, l.$4 * h),
        linePaint,
      );
    }

    for (final s in _stars) {
      final twinkle = math.sin((progress + s.$4) * 2 * math.pi) * 0.5 + 0.5;
      final alpha = (70 + 140 * twinkle).round();
      final r = s.$3 * (0.75 + 0.25 * twinkle);
      final cx = s.$1 * w;
      final cy = s.$2 * h;

      canvas.drawCircle(
        Offset(cx, cy),
        r * 4,
        Paint()
          ..color = color.withAlpha((22 * twinkle).round())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()..color = Colors.white.withAlpha(alpha),
      );

      if (s.$3 > 1.9) {
        final arm = r * 3.5 * (0.4 + 0.6 * twinkle);
        final armPaint = Paint()
          ..color = Colors.white.withAlpha((alpha * 0.35).round())
          ..strokeWidth = 0.7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), armPaint);
        canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), armPaint);
      }
    }
  }

  @override
  bool shouldRepaint(StarlightPainter old) =>
      old.progress != progress || old.color != color;
}
