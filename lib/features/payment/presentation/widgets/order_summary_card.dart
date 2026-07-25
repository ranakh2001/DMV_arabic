import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';

/// Glass card summarizing the plan and price being purchased, at the top
/// of the payment screen.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.planTitle,
    required this.periodSuffix,
    required this.price,
  });

  final String planTitle;
  final String periodSuffix;
  final String price;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 18,
      padding: EdgeInsets.all(context.sp(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.t('payment.order_summary'),
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(13),
              fontWeight: FontWeight.w700,
              color: context.appTextSecondary,
            ),
          ),
          SizedBox(height: context.sp(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.w800,
                  color: context.appPrimary,
                ),
              ),
              Text(
                '$planTitle · $periodSuffix',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
