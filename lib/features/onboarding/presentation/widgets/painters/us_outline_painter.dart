import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Stylized US outline drawn behind the onboarding page 3 state picker.
class UsOutlinePainter extends CustomPainter {
  const UsOutlinePainter({required this.color});

  final Color color;

  // Geographic coordinate space: x in [0,100] (lon -124.8 to -66.9),
  // y in [0,60] (lat 49.0 to 24.5). Traced clockwise from the NW corner.
  static const List<(double, double)> _outline = [
    (0.2, 1.5),
    (0.2, 2.9),
    (1.4, 6.9),
    (0.9, 11.8),
    (0.4, 15.0),
    (0.7, 19.6),
    (3.8, 27.5),
    (4.8, 30.4),
    (7.4, 35.5),
    (11.4, 36.8),
    (13.2, 39.7),
    (13.3, 40.2),
    (17.3, 40.2),
    (23.7, 43.1),
    (31.7, 41.9),
    (41.4, 47.8),
    (43.8, 52.5),
    (47.2, 56.7),
    (47.4, 52.5),
    (51.9, 48.8),
    (53.5, 47.3),
    (55.0, 48.0),
    (60.0, 47.3),
    (61.4, 49.8),
    (62.8, 46.3),
    (63.7, 46.6),
    (65.4, 46.1),
    (67.5, 46.1),
    (69.0, 47.8),
    (71.5, 47.3),
    (73.0, 53.2),
    (74.4, 58.8),
    (74.4, 60.0),
    (77.2, 56.7),
    (76.5, 50.0),
    (75.8, 48.4),
    (74.9, 44.7),
    (75.5, 41.6),
    (79.1, 37.5),
    (81.0, 36.7),
    (83.0, 35.0),
    (85.2, 33.6),
    (84.5, 29.6),
    (84.3, 29.1),
    (86.2, 26.5),
    (86.4, 25.0),
    (87.9, 20.8),
    (89.6, 20.6),
    (91.4, 19.4),
    (93.0, 17.2),
    (94.7, 16.9),
    (93.6, 18.0),
    (93.1, 16.3),
    (93.6, 15.7),
    (93.4, 14.5),
    (94.3, 13.1),
    (97.9, 11.4),
    (100.0, 10.5),
    (92.9, 9.1),
    (89.1, 9.8),
    (87.6, 9.8),
    (83.3, 13.1),
    (79.1, 14.3),
    (72.7, 18.0),
    (69.1, 18.0),
    (64.3, 17.6),
    (63.9, 12.2),
    (63.4, 9.8),
    (58.6, 5.9),
    (56.5, 5.4),
    (47.7, 0.0),
    (35.9, 0.0),
    (15.2, 0.0),
    (3.1, 0.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final scale = math.min(w / 100.0, h / 60.0);
    final ox = (w - 100 * scale) / 2;
    final oy = (h - 60 * scale) / 2;

    Offset pt(double x, double y) => Offset(ox + x * scale, oy + y * scale);

    final first = pt(_outline[0].$1, _outline[0].$2);
    final path = Path()..moveTo(first.dx, first.dy);
    for (var i = 1; i < _outline.length; i++) {
      final p = pt(_outline[i].$1, _outline[i].$2);
      path.lineTo(p.dx, p.dy);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color.withAlpha(22));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(UsOutlinePainter old) => old.color != color;
}
