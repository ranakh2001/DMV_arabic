import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// The "select your state" field on the register screen — opens the shared
/// state picker sheet and displays the current selection.
class RegisterStateDropdownField extends StatelessWidget {
  const RegisterStateDropdownField({super.key, required this.selectedState, required this.onTap});

  final String? selectedState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedState != null;
    final accent = context.appPrimary;
    final valueColor = hasValue ? context.appTextPrimary : context.appTextSecondary;
    final isRtl = context.isRtl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: hasValue ? accent : accent.withAlpha(60), width: hasValue ? 1.5 : 1),
        ),
        // Layout is pinned LTR so the chevron/icon sit on the same physical
        // side regardless of locale — only the text alignment follows RTL.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              Icon(Icons.keyboard_arrow_down_rounded, color: accent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedState ?? context.t('field.state_hint'),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: TextStyle(fontFamily: 'Almarai', fontSize: 14, color: valueColor),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.map_outlined, color: accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
