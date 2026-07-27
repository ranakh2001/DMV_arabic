import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// One selectable answer row. Content may be text, an icon (image-style
/// answer), or both — reused for every question regardless of answer type.
class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.letter,
    this.text,
    this.icon,
    required this.selected,
    required this.onTap,
  }) : assert(text != null || icon != null, 'An option needs text and/or an icon.');

  final String letter;
  final String? text;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? context.appPrimary : context.appGlassBorder;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.sp(14), vertical: context.sp(14)),
        decoration: BoxDecoration(
          color: selected ? context.appPrimary.withAlpha(28) : context.appGlassTint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            _LetterBadge(letter: letter, selected: selected),
            SizedBox(width: context.sp(12)),
            Expanded(
              child: Row(
                mainAxisAlignment: text == null ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  if (icon != null)
                    Icon(icon, size: context.sp(26), color: selected ? context.appPrimary : context.appTextSecondary),
                  if (icon != null && text != null) SizedBox(width: context.sp(10)),
                  if (text != null)
                    Expanded(
                      child: Text(
                        text!,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: context.sp(14),
                          fontWeight: FontWeight.w600,
                          color: context.appTextPrimary,
                          height: 1.5,
                        ),
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

class _LetterBadge extends StatelessWidget {
  const _LetterBadge({required this.letter, required this.selected});

  final String letter;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sp(28),
      height: context.sp(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? context.appPrimary : Colors.transparent,
        border: Border.all(color: selected ? context.appPrimary : context.appTextSecondary),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: context.sp(13),
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : context.appTextSecondary,
        ),
      ),
    );
  }
}
