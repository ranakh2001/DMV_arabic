import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Settings row: master push-notification permission switch, wired to
/// `notificationSettingsProvider`.
class NotificationsToggleRow extends StatelessWidget {
  const NotificationsToggleRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(10)),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_rounded,
            size: context.sp(20),
            color: context.appPrimary,
          ),
          SizedBox(width: context.sp(12)),
          Expanded(
            child: Text(
              context.t('notif.push'),
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(15),
                fontWeight: FontWeight.w600,
                color: context.appTextPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.appPrimary,
          ),
        ],
      ),
    );
  }
}
