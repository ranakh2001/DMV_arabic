import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import 'settings_segment_button.dart';

/// Settings row with a three-segment System/Light/Dark pill switch, wired
/// directly to [themeModeProvider].
class ThemeToggleRow extends StatelessWidget {
  const ThemeToggleRow({super.key, required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dark_mode_outlined, size: context.sp(20), color: context.appPrimary),
              SizedBox(width: context.sp(12)),
              Flexible(
                child: Text(
                  context.t('profile.ui_theme'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w600,
                    color: context.appTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(10)),
          Row(
            children: [
              SettingsSegmentButton(
                label: context.t('settings.theme.system'),
                selected: mode == ThemeMode.system,
                onTap: () => onChanged(ThemeMode.system),
                horizontalPadding: 12,
                verticalPadding: 4,
                fontSize: 12,
              ),
              const SizedBox(width: 6),
              SettingsSegmentButton(
                label: context.t('settings.theme.light'),
                selected: mode == ThemeMode.light,
                onTap: () => onChanged(ThemeMode.light),
                horizontalPadding: 12,
                verticalPadding: 4,
                fontSize: 12,
              ),
              const SizedBox(width: 6),
              SettingsSegmentButton(
                label: context.t('settings.theme.dark'),
                selected: mode == ThemeMode.dark,
                onTap: () => onChanged(ThemeMode.dark),
                horizontalPadding: 12,
                verticalPadding: 4,
                fontSize: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
