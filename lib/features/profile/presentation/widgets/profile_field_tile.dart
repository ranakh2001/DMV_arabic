import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// One editable "label / value" row inside the profile fields card
/// (full name, email, phone, photo). Tapping the pencil icon triggers
/// [onEdit] — the caller decides what editing means (text dialog, picker, …).
class ProfileFieldTile extends StatelessWidget {
  const ProfileFieldTile({
    super.key,
    required this.label,
    required this.onEdit,
    this.value,
    this.leading,
  }) : assert(
         value != null || leading != null,
         'Provide either value or leading.',
       );

  final String label;
  final VoidCallback onEdit;

  /// Plain text value (e.g. the user's name). Ignored if [leading] is set.
  final String? value;

  /// Custom leading content replacing the value text (e.g. a mini avatar).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.sp(12)),
        child: Row(
          children: [
            Icon(
              Icons.edit_rounded,
              size: context.sp(18),
              color: context.appPrimary,
            ),
            SizedBox(width: context.sp(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(13),
                      color: context.appTextSecondary,
                    ),
                  ),
                  SizedBox(height: context.sp(4)),
                  leading ??
                      Text(
                        value!,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w700,
                          color: context.appTextPrimary,
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
