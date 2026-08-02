import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared pill-shaped segment button used by [LanguageToggleRow] and
/// [ThemeToggleRow] (English/Arabic and System/Light/Dark switches).
class SettingsSegmentButton extends StatelessWidget {
  const SettingsSegmentButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.horizontalPadding = 10,
    this.verticalPadding = 4,
    this.fontSize = 11,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // Not routed through context.sp(): sp() floors every value to 15px
        // (the Arabic body-text accessibility minimum), which would force
        // this padding to 15 regardless of what's passed here.
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: selected ? context.appPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? context.appPrimary : context.appGlassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(fontSize),
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : context.appTextSecondary,
          ),
        ),
      ),
    );
  }
}
