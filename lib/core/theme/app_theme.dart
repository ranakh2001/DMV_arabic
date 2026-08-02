import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'glass_effect_theme.dart';

/// Builds [ThemeData] for light and dark modes. Widgets never call raw Color
/// constructors — they always read from [Theme.of(context)] or [AppColors].
abstract final class AppTheme {
  static ThemeData light(BuildContext context) => _build(
    context: context,
    brightness: Brightness.light,
    background: AppColorsLight.background,
    surface: AppColorsLight.surface,
    surfaceVariant: const Color(0xFFE8EEF7),
    primary: AppColorsLight.primary,
    secondary: AppColorsLight.secondary,
    tertiary: AppColorsLight.success,
    error: AppColorsLight.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColorsLight.textPrimary,
    onSurfaceVariant: AppColorsLight.textSecondary,
    outline: AppColorsLight.textDisabled,
  );

  static ThemeData dark(BuildContext context) => _build(
    context: context,
    brightness: Brightness.dark,
    background: AppColorsDark.background,
    surface: AppColorsDark.background,
    surfaceVariant: AppColorsDark.surface,
    primary: AppColorsDark.primary,
    secondary: AppColorsDark.secondary,
    tertiary: AppColorsDark.success,
    error: AppColorsDark.error,
    onPrimary: Colors.white,
    onSecondary: AppColorsDark.background,
    onSurface: AppColorsDark.textPrimary,
    onSurfaceVariant: AppColorsDark.textSecondary,
    outline: AppColorsDark.textDisabled,
  );

  static ThemeData _build({
    required BuildContext context,
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color primary,
    required Color secondary,
    required Color tertiary,
    required Color error,
    required Color onPrimary,
    required Color onSecondary,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
  }) {
    final cs = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      tertiary: tertiary,
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outline.withAlpha(80),
      scrim: Colors.black54,
      shadow: Colors.black38,
      inverseSurface: onSurface,
      onInverseSurface: surface,
      inversePrimary: secondary,
      primaryContainer: primary.withAlpha(30),
      onPrimaryContainer: primary,
      secondaryContainer: secondary.withAlpha(30),
      onSecondaryContainer: secondary,
      tertiaryContainer: tertiary.withAlpha(30),
      onTertiaryContainer: tertiary,
      errorContainer: error.withAlpha(30),
      onErrorContainer: error,
      surfaceTint: primary,
      surfaceContainer: surfaceVariant,
      surfaceContainerLow: surface,
      surfaceContainerLowest: background,
      surfaceContainerHigh: surfaceVariant,
    );

    final textTheme = AppTypography.textTheme(context, onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant.withAlpha(120),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline.withAlpha(100)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        errorStyle: textTheme.labelSmall?.copyWith(color: error),
      ),
      cardTheme: CardThemeData(
        color: surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: outline.withAlpha(60),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: [
        brightness == Brightness.dark
            ? GlassEffectTheme.dark
            : GlassEffectTheme.light,
      ],
    );
  }
}
