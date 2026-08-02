import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Compact pill button showing the *other* language's label — tapping it
/// switches to that language. Used in headers where a full two-segment
/// switch (see `LanguageToggleRow`) would be too wide.
class LanguageToggleChip extends StatelessWidget {
  const LanguageToggleChip({
    super.key,
    required this.isArabic,
    required this.onChanged,
  });

  final bool isArabic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final targetLabel = isArabic
        ? context.t('settings.language.en')
        : context.t('settings.language.ar');
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () => onChanged(!isArabic),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(14),
          vertical: context.sp(7),
        ),
        decoration: BoxDecoration(
          color: context.appGlassTint,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: context.appGlassBorder),
        ),
        child: Text(
          targetLabel,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(13),
            fontWeight: FontWeight.w700,
            color: context.appPrimary,
          ),
        ),
      ),
    );
  }
}
