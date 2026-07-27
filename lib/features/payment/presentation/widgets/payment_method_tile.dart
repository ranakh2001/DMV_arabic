import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_method.dart';

/// Selectable row for one payment rail, used in the payment method list.
/// Reused for all three [PaymentMethodType] options so the selection
/// styling lives in a single place.
class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethodType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: context.sp(16), vertical: context.sp(14)),
        decoration: BoxDecoration(
          color: selected ? accent.withAlpha(24) : context.appSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? accent : context.appGlassBorder, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              size: context.sp(20),
              color: selected ? accent : context.appTextDisabled,
            ),
            SizedBox(width: context.sp(12)),
            Icon(type.icon, size: context.sp(20), color: context.appTextPrimary),
            SizedBox(width: context.sp(10)),
            Expanded(
              child: Text(
                context.t(type.labelKey),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.w600,
                  color: context.appTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
