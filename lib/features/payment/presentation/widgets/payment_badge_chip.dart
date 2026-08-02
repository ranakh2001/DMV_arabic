import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_method.dart';

/// Small icon+label chip for a payment rail. Used both as a trust badge on
/// the subscription screen and as the base look for the selectable
/// [PaymentMethodTile] on the payment screen.
class PaymentBadgeChip extends StatelessWidget {
  const PaymentBadgeChip({super.key, required this.type});

  final PaymentMethodType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(14),
        vertical: context.sp(10),
      ),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appGlassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: context.sp(18), color: context.appTextPrimary),
          SizedBox(width: context.sp(6)),
          Text(
            context.t(type.labelKey),
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(12),
              fontWeight: FontWeight.w700,
              color: context.appTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
