import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Home screen header: app branding at the start (right, in RTL) and the
/// user's avatar + notification bell at the end (left).
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.onAvatarTap,
    required this.onNotificationsTap,
  });

  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.directions_car_filled_rounded,
              color: context.appPrimary,
              size: context.sp(24),
            ),
            SizedBox(width: context.sp(8)),
            Text(
              context.t('app.name'),
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(19),
                fontWeight: FontWeight.w800,
                color: context.appTextPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _CircleIconButton(
              icon: Icons.notifications_outlined,
              tooltip: context.t('home.no_notifications'),
              onTap: onNotificationsTap,
              iconColor: context.appPrimary,
            ),
            SizedBox(width: context.sp(10)),
            _AvatarButton(onTap: onAvatarTap),
          ],
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 100,
      padding: EdgeInsets.zero,
      width: context.sp(42),
      height: context.sp(42),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: iconColor ?? context.appTextPrimary,
              size: context.sp(20),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: CircleAvatar(
        radius: context.sp(21),
        backgroundColor: context.appPrimary.withAlpha(40),
        child: Icon(
          Icons.person_rounded,
          color: context.appPrimary,
          size: context.sp(22),
        ),
      ),
    );
  }
}
