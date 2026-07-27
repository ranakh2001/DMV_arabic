import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

const _kSubscribeOrange = Color(0xFFFF8A3D);

/// Premium-upsell glass banner. Uses a warm accent tint so it stands out
/// from the app's primary-blue glass cards.
class SubscribeBanner extends StatelessWidget {
  const SubscribeBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: GlassContainer(
        radius: 20,
        tint: _kSubscribeOrange.withAlpha(30),
        border: _kSubscribeOrange.withAlpha(90),
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(16),
          vertical: context.sp(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: context.sp(38),
                    height: context.sp(38),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _kSubscribeOrange, width: 1.4),
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: _kSubscribeOrange,
                      size: context.sp(20),
                    ),
                  ),
                  SizedBox(width: context.sp(12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.t('home.subscribe_title'),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w700,
                          color: context.appTextPrimary,
                        ),
                      ),
                      Text(
                        context.t('home.subscribe_subtitle'),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: context.sp(13),
                          color: context.appTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: context.sp(10)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(18),
                vertical: context.sp(10),
              ),
              decoration: BoxDecoration(
                color: _kSubscribeOrange,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: _kSubscribeOrange.withAlpha(110),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                context.t('home.subscribe_cta'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
