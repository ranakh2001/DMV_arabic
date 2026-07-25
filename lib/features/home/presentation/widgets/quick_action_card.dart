import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Square glass action tile used in the home-screen quick-actions row
/// (reused for both "My Stats" and "Quick Test").
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: GlassContainer(
        radius: 18,
        padding: EdgeInsets.symmetric(vertical: context.sp(18)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.sp(44),
              height: context.sp(44),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.appPrimary.withAlpha(30),
              ),
              child: Icon(icon, color: context.appPrimary, size: context.sp(22)),
            ),
            SizedBox(height: context.sp(10)),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(14),
                fontWeight: FontWeight.w600,
                color: context.appTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
