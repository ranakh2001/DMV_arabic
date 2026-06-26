import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A frosted-glass container that adapts to light and dark themes.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.15,
    this.radius = 16.0,
    this.tint,
    this.border,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double radius;
  final Color? tint;
  final Color? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveTint = tint ?? context.appGlassTint;
    final effectiveBorder = border ?? context.appGlassBorder;
    final tintWithOpacity = effectiveTint.withValues(alpha: opacity);

    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tintWithOpacity,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: effectiveBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassDecoration extends Decoration {
  const GlassDecoration({
    required this.tint,
    required this.border,
    this.radius = 16.0,
  });

  final Color tint;
  final Color border;
  final double radius;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _GlassPainter(tint: tint, border: border, radius: radius);
}

class _GlassPainter extends BoxPainter {
  _GlassPainter({required this.tint, required this.border, required this.radius});

  final Color tint;
  final Color border;
  final double radius;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final rect = offset & (config.size ?? Size.zero);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect, Paint()..color = tint);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
