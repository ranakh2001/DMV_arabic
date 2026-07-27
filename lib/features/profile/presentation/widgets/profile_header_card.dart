import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

const _kGoldAccent = Color(0xFFF5A623);

/// Avatar (with edit badge) + name + email + subscriber chip, centered at
/// the top of the profile screen.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.onEditAvatar,
  });

  final String name;
  final String email;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: context.sp(48),
              backgroundColor: context.appPrimary.withAlpha(35),
              child: Icon(Icons.person_rounded, color: context.appPrimary, size: context.sp(52)),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              bottom: -2,
              end: -2,
              child: InkWell(
                onTap: onEditAvatar,
                customBorder: const CircleBorder(),
                child: Container(
                  width: context.sp(32),
                  height: context.sp(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appPrimary,
                    border: Border.all(color: context.appBackground, width: 2),
                  ),
                  child: Icon(Icons.edit_rounded, color: Colors.white, size: context.sp(16)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.sp(14)),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(20),
            fontWeight: FontWeight.w800,
            color: context.appTextPrimary,
          ),
        ),
        SizedBox(height: context.sp(4)),
        Text(
          email,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(14),
            color: context.appTextSecondary,
          ),
        ),
        SizedBox(height: context.sp(10)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.sp(14), vertical: context.sp(6)),
          decoration: BoxDecoration(
            color: _kGoldAccent.withAlpha(30),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: _kGoldAccent.withAlpha(110)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: _kGoldAccent, size: context.sp(15)),
              SizedBox(width: context.sp(6)),
              Text(
                context.t('profile.subscriber'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w700,
                  color: _kGoldAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
