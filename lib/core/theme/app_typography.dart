import 'package:flutter/material.dart';
import '../responsive/responsive_extensions.dart';

/// Typography using Almarai. All sizes via [context.sp]
/// so they scale with screen width and respect accessibility scaling.
/// Arabic body text is never below 15pt per spec.
abstract final class AppTypography {
  static TextTheme textTheme(BuildContext context, Color textColor) {
    return TextTheme(
      // Display
      displayLarge: _style(context, 57, FontWeight.w700, textColor),
      displayMedium: _style(context, 45, FontWeight.w700, textColor),
      displaySmall: _style(context, 36, FontWeight.w700, textColor),

      // Headline
      headlineLarge: _style(context, 32, FontWeight.w700, textColor),
      headlineMedium: _style(context, 28, FontWeight.w600, textColor),
      headlineSmall: _style(context, 24, FontWeight.w600, textColor),

      // Title
      titleLarge: _style(context, 22, FontWeight.w600, textColor),
      titleMedium: _style(context, 18, FontWeight.w500, textColor),
      titleSmall: _style(context, 16, FontWeight.w500, textColor),

      // Body — Arabic minimum 15pt enforced in [_style]
      bodyLarge: _style(context, 16, FontWeight.w400, textColor),
      bodyMedium: _style(context, 15, FontWeight.w400, textColor),
      bodySmall: _style(context, 15, FontWeight.w400, textColor),

      // Label
      labelLarge: _style(context, 16, FontWeight.w600, textColor),
      labelMedium: _style(context, 15, FontWeight.w500, textColor),
      labelSmall: _style(context, 13, FontWeight.w400, textColor),
    );
  }

  static TextStyle _style(
    BuildContext context,
    double size,
    FontWeight weight,
    Color color,
  ) {
    // Arabic minimum 15pt; also scale with screen width
    final scaled = context.sp(size.clamp(15.0, double.infinity));
    return TextStyle(
      fontFamily: 'Almarai',
      fontSize: scaled,
      fontWeight: weight,
      color: color,
      height: 1.6,
    );
  }

  static TextStyle almarai(
    BuildContext context, {
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: 'Almarai',
        fontSize: context.sp(size.clamp(15.0, double.infinity)),
        fontWeight: weight,
        color: color,
        height: 1.5,
      );
}
