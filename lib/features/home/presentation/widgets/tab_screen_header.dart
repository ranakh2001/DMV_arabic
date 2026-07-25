import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Centered bold title used at the top of the non-Home bottom-nav tabs
/// (My Account, My Stats, Simulation) — mirrors the plain title bar in the
/// source design, without a back button since these are root tab screens.
class TabScreenHeader extends StatelessWidget {
  const TabScreenHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: context.sp(19),
          fontWeight: FontWeight.w800,
          color: context.appTextPrimary,
        ),
      ),
    );
  }
}
