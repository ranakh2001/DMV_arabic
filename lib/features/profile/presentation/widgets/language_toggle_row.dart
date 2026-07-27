import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import 'settings_segment_button.dart';

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
          Icon(Icons.language_rounded, size: context.sp(20), color: context.appPrimary),
          SizedBox(width: context.sp(12)),
          Flexible(
            child: Text(
              context.t('profile.ui_language'),
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(15),
                fontWeight: FontWeight.w600,
                color: context.appTextPrimary,
              ),
            ),
          ),
          SizedBox(width: context.sp(8)),
          SettingsSegmentButton(
            label: context.t('settings.language.en'),
            selected: !isArabic,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 4),
          SettingsSegmentButton(
            label: context.t('settings.language.ar'),
            selected: isArabic,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}
