import 'package:flutter/material.dart';
import '../responsive/responsive_extensions.dart';
import '../theme/app_colors.dart';

/// Shared header for secondary screens reached by pushing a route: a back
/// button, a centered bold title, and an optional [trailing] widget (falls
/// back to a spacer the same width as the back button, so the title stays
/// visually centered).
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.sp(12), context.sp(10), context.sp(16), context.sp(6)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_rounded, color: context.appTextPrimary),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(18),
                fontWeight: FontWeight.w800,
                color: context.appTextPrimary,
              ),
            ),
          ),
          trailing ?? SizedBox(width: context.sp(48)),
        ],
      ),
    );
  }
}
