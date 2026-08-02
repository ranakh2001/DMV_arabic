import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Glass row with the "auto-renew" label and its toggle switch.
class AutoRenewSwitchRow extends StatelessWidget {
  const AutoRenewSwitchRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 16,
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(16),
        vertical: context.sp(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.appPrimary,
          ),
          Text(
            context.t('subscription.auto_renew'),
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(15),
              fontWeight: FontWeight.w600,
              color: context.appTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
