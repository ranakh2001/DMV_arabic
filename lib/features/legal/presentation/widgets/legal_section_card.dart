import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// A single numbered or iconed section within a legal document: a small
/// badge (number or icon), a bold title, and either a paragraph of [body]
/// text or a set of [children] (e.g. a checklist).
class LegalSectionCard extends StatelessWidget {
  const LegalSectionCard({
    super.key,
    this.number,
    this.icon,
    required this.title,
    this.body,
    this.children,
  }) : assert(
         number != null || icon != null,
         'Provide either a number or an icon.',
       ),
       assert(
         body != null || children != null,
         'Provide either body text or children.',
       );

  final int? number;
  final IconData? icon;
  final String title;
  final String? body;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      padding: EdgeInsets.all(context.sp(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: context.sp(34),
                height: context.sp(34),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appPrimary.withAlpha(30),
                ),
                alignment: Alignment.center,
                child: number != null
                    ? Text(
                        '$number',
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w800,
                          color: context.appPrimary,
                        ),
                      )
                    : Icon(
                        icon,
                        size: context.sp(17),
                        color: context.appPrimary,
                      ),
              ),
              SizedBox(width: context.sp(10)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(12)),
          if (body != null)
            Text(
              body!,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(14),
                color: context.appTextSecondary,
                height: 1.7,
              ),
            ),
          ...?children,
        ],
      ),
    );
  }
}
