import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Centered, bordered callout used to surface a single reassuring
/// statement (e.g. "we protect your rights and data") between sections.
class LegalHighlightBanner extends StatelessWidget {
  const LegalHighlightBanner({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(16),
        vertical: context.sp(14),
      ),
      decoration: BoxDecoration(
        color: context.appPrimary.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appPrimary.withAlpha(70)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: context.sp(18), color: context.appPrimary),
          SizedBox(width: context.sp(10)),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(14),
                fontWeight: FontWeight.w700,
                color: context.appPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
