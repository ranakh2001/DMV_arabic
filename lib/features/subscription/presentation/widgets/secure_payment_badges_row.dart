import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../payment/domain/entities/payment_method.dart';
import '../../../payment/presentation/widgets/payment_badge_chip.dart';

/// Trust row at the bottom of the subscription screen listing the accepted
/// (mock) payment rails.
class SecurePaymentBadgesRow extends StatelessWidget {
  const SecurePaymentBadgesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.t('subscription.secure_payment'),
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: context.sp(13),
            fontWeight: FontWeight.w600,
            color: context.appTextSecondary,
          ),
        ),
        SizedBox(height: context.sp(12)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: context.sp(10),
          runSpacing: context.sp(10),
          children: PaymentMethodType.values.map((type) => PaymentBadgeChip(type: type)).toList(),
        ),
      ],
    );
  }
}
