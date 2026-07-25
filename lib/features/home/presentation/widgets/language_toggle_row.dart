import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Settings row with a two-segment English/Arabic pill switch, wired
/// directly to [localeProvider] — this one is real, not a stub.
class LanguageToggleRow extends StatelessWidget {
  const LanguageToggleRow({super.key, required this.isArabic, required this.onChanged});

  final bool isArabic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(10)),
      child: Row(
        children: [
          _Segment(
            label: context.t('settings.language.en'),
            selected: !isArabic,
            onTap: () => onChanged(false),
          ),
          SizedBox(width: context.sp(6)),
          _Segment(
            label: context.t('settings.language.ar'),
            selected: isArabic,
            onTap: () => onChanged(true),
          ),
          const Spacer(),
          Text(
            context.t('profile.ui_language'),
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(15),
              fontWeight: FontWeight.w600,
              color: context.appTextPrimary,
            ),
          ),
          SizedBox(width: context.sp(12)),
          Icon(Icons.language_rounded, size: context.sp(20), color: context.appPrimary),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: context.sp(14), vertical: context.sp(7)),
        decoration: BoxDecoration(
          color: selected ? context.appPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? context.appPrimary : context.appGlassBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(13),
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : context.appTextSecondary,
          ),
        ),
      ),
    );
  }
}
