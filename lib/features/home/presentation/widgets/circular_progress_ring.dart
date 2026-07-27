import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Small ring showing "answered/total" progress (e.g. "23/46") — used on the
/// "continue where you left off" card.
class CircularProgressRing extends StatelessWidget {
  const CircularProgressRing({
    super.key,
    required this.value,
    this.centerText,
    this.center,
    this.size = 56,
    this.strokeWidth = 5,
  }) : assert(
          centerText != null || center != null,
          'Provide either centerText or center.',
        );

  /// 0.0–1.0
  final double value;

  /// Simple center label. Ignored if [center] is provided.
  final String? centerText;

  /// Custom center content (e.g. a multi-line stat block). Takes priority
  /// over [centerText] when both would otherwise apply.
  final Widget? center;

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final dimension = context.sp(size);
    return SizedBox(
      width: dimension,
      height: dimension,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(dimension, dimension),
            painter: _RingPainter(
              value: value,
              strokeWidth: context.sp(strokeWidth),
              trackColor: context.appTextDisabled.withAlpha(60),
              progressColor: context.appPrimary,
            ),
          ),
          center ??
              Text(
                centerText!,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double value;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final progress = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * value.clamp(0.0, 1.0),
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
