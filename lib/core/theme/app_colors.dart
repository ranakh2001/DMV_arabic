import 'package:flutter/material.dart';

abstract final class _Palette {
  static const Color primary = Color(0xFF4A9CD9);
  static const Color secondary = Color(0xFF5FC3FF);
  static const Color tertiary = Color(0xFF0D1B3E);
  static const Color neutral = Color(0xFF0A0E1A);

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);

  static const Color lightBackground = Color(0xFFF4F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0D1B3E);
  static const Color lightTextSecondary = Color(0xFF4A5568);
  static const Color lightTextDisabled = Color(0xFFAFBBC9);
  static const Color lightGlassTint = Color(0x1A4A9CD9);
  static const Color lightGlassBorder = Color(0x334A9CD9);

  static const Color darkBackground = neutral;
  static const Color darkSurface = tertiary;
  static const Color darkTextPrimary = Color(0xFFE8EEF7);
  static const Color darkTextSecondary = Color(0xFF8FA3BF);
  static const Color darkTextDisabled = Color(0xFF3D4F65);
  static const Color darkGlassTint = Color(0x1A5FC3FF);
  static const Color darkGlassBorder = Color(0x335FC3FF);
}

final class AppColorsLight {
  const AppColorsLight._();

  static const Color primary = _Palette.primary;
  static const Color secondary = _Palette.secondary;
  static const Color background = _Palette.lightBackground;
  static const Color surface = _Palette.lightSurface;
  static const Color textPrimary = _Palette.lightTextPrimary;
  static const Color textSecondary = _Palette.lightTextSecondary;
  static const Color textDisabled = _Palette.lightTextDisabled;
  static const Color glassTint = _Palette.lightGlassTint;
  static const Color glassBorder = _Palette.lightGlassBorder;
  static const Color success = _Palette.success;
  static const Color error = _Palette.error;
}

final class AppColorsDark {
  const AppColorsDark._();

  static const Color primary = _Palette.primary;
  static const Color secondary = _Palette.secondary;
  static const Color background = _Palette.darkBackground;
  static const Color surface = _Palette.darkSurface;
  static const Color textPrimary = _Palette.darkTextPrimary;
  static const Color textSecondary = _Palette.darkTextSecondary;
  static const Color textDisabled = _Palette.darkTextDisabled;
  static const Color glassTint = _Palette.darkGlassTint;
  static const Color glassBorder = _Palette.darkGlassBorder;
  static const Color success = _Palette.success;
  static const Color error = _Palette.error;
}

extension AppColors on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  Color get appPrimary => cs.primary;
  Color get appSecondary => cs.secondary;
  Color get appBackground => cs.surface;
  Color get appSurface => cs.surfaceContainerHighest;
  Color get appError => cs.error;
  Color get appTextPrimary => cs.onSurface;
  Color get appTextSecondary => cs.onSurfaceVariant;
  Color get appTextDisabled => cs.outline;
  Color get appSuccess => cs.tertiary;
  Color get appGlassTint => Theme.of(this).brightness == Brightness.dark
      ? AppColorsDark.glassTint
      : AppColorsLight.glassTint;
  Color get appGlassBorder => Theme.of(this).brightness == Brightness.dark
      ? AppColorsDark.glassBorder
      : AppColorsLight.glassBorder;
}
