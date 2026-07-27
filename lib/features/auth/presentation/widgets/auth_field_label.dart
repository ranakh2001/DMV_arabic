import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Label above a form field in the auth flow (e.g. "الاسم الكامل").
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Almarai',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.appTextPrimary,
      ),
    );
  }
}
