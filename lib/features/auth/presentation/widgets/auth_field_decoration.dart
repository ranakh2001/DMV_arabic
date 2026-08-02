import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared input decoration for every text field in the auth flow — an
/// accent-tinted fill/border so fields read clearly against the glass
/// cards. Used by name/phone/state fields directly, and by
/// [authPasswordDecoration] for password fields.
InputDecoration authFieldDecoration({
  required BuildContext context,
  required String hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  final accent = context.appPrimary;
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontFamily: 'Almarai',
      color: context.appTextSecondary,
      fontSize: 14,
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: context.appSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: accent.withAlpha(60)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: accent.withAlpha(60)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.appError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.appError, width: 1.5),
    ),
    errorStyle: const TextStyle(fontFamily: 'Almarai', fontSize: 12),
  );
}

/// Password-field variant of [authFieldDecoration]: lock icon + a
/// visibility-toggle suffix.
InputDecoration authPasswordDecoration({
  required BuildContext context,
  required String hint,
  required bool obscure,
  required VoidCallback onToggle,
}) {
  final accent = context.appPrimary;
  return authFieldDecoration(
    context: context,
    hint: hint,
    prefixIcon: Icon(Icons.lock_outline_rounded, color: accent, size: 20),
    suffixIcon: IconButton(
      icon: Icon(
        obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
        color: accent,
        size: 20,
      ),
      onPressed: onToggle,
    ),
  );
}
