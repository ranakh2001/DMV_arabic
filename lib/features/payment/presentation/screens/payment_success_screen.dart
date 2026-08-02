import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Confirmation shown right after a successful Stripe payment. "Start Now"
/// pops back to the app root — by then [subscriptionProvider] already
/// reports the user as subscribed, so [AuthGate] resolves to the home shell.
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key, this.activationPending = false});

  /// True when the charge succeeded but the backend hadn't confirmed
  /// activation yet after polling — shows a "hang tight" message instead of
  /// claiming the subscription is already fully active.
  final bool activationPending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isDesktop || context.isTablet
                  ? 480
                  : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sp(32)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: context.sp(96),
                    height: context.sp(96),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.appSuccess.withAlpha(30),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: context.appSuccess,
                      size: context.sp(52),
                    ),
                  ),
                  SizedBox(height: context.sp(28)),
                  Text(
                    context.t('payment.success.title'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(24),
                      fontWeight: FontWeight.w800,
                      color: context.appTextPrimary,
                    ),
                  ),
                  SizedBox(height: context.sp(10)),
                  Text(
                    activationPending
                        ? context.t('payment.activation_pending')
                        : context.t('payment.success.subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: context.sp(15),
                      color: context.appTextSecondary,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: context.sp(36)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                      child: Text(context.t('payment.success.start')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
