import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralizes the frosted-glass look (blur, opacity, corner radius, tint,
/// border) so [GlassContainer] and any other glass surface pull from one
/// place instead of hardcoding values per screen.
@immutable
class GlassEffectTheme extends ThemeExtension<GlassEffectTheme> {
  const GlassEffectTheme({
    required this.blur,
    required this.opacity,
    required this.radius,
    required this.tint,
    required this.border,
  });

  final double blur;
  final double opacity;
  final double radius;
  final Color tint;
  final Color border;

  static const light = GlassEffectTheme(
    blur: 12.0,
    opacity: 0.15,
    radius: 16.0,
    tint: AppColorsLight.glassTint,
    border: AppColorsLight.glassBorder,
  );

  static const dark = GlassEffectTheme(
    blur: 12.0,
    opacity: 0.15,
    radius: 16.0,
    tint: AppColorsDark.glassTint,
    border: AppColorsDark.glassBorder,
  );

  @override
  GlassEffectTheme copyWith({
    double? blur,
    double? opacity,
    double? radius,
    Color? tint,
    Color? border,
  }) {
    return GlassEffectTheme(
      blur: blur ?? this.blur,
      opacity: opacity ?? this.opacity,
      radius: radius ?? this.radius,
      tint: tint ?? this.tint,
      border: border ?? this.border,
    );
  }

  @override
  GlassEffectTheme lerp(ThemeExtension<GlassEffectTheme>? other, double t) {
    if (other is! GlassEffectTheme) return this;
    return GlassEffectTheme(
      blur: blur + (other.blur - blur) * t,
      opacity: opacity + (other.opacity - opacity) * t,
      radius: radius + (other.radius - radius) * t,
      tint: Color.lerp(tint, other.tint, t) ?? tint,
      border: Color.lerp(border, other.border, t) ?? border,
    );
  }
}
