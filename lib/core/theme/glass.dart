import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_effect_theme.dart';

/// A frosted-glass container that adapts to light and dark themes. Blur,
/// opacity, radius, tint and border all default to [GlassEffectTheme] —
/// pass a value here only when a specific card needs to deviate from it.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blur,
    this.opacity,
    this.radius,
    this.tint,
    this.border,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.boxShadow,
  });

  final Widget child;
  final double? blur;
  final double? opacity;
  final double? radius;
  final Color? tint;
  final Color? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  /// Optional outer glow/drop shadow (e.g. the auth flow's card glow).
  /// Drawn outside the blurred clip so it isn't affected by [radius]'s clip.
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final glassTheme = Theme.of(context).extension<GlassEffectTheme>()!;
    final effectiveBlur = blur ?? glassTheme.blur;
    final effectiveOpacity = opacity ?? glassTheme.opacity;
    final effectiveRadius = radius ?? glassTheme.radius;
    final effectiveTint = tint ?? glassTheme.tint;
    final effectiveBorder = border ?? glassTheme.border;
    final tintWithOpacity = effectiveTint.withValues(alpha: effectiveOpacity);

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: boxShadow == null
          ? null
          : BoxDecoration(boxShadow: boxShadow),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tintWithOpacity,
              borderRadius: BorderRadius.circular(effectiveRadius),
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
  _GlassPainter({
    required this.tint,
    required this.border,
    required this.radius,
  });

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
