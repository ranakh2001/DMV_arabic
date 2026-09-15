import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../payment/presentation/screens/payment_success_screen.dart';
import '../../../payment/presentation/widgets/order_summary_card.dart';
import '../../../subscription/domain/entities/subscription_plan.dart';

/// Checkout step for a chosen [SubscriptionPlan] on iOS — Apple In-App
/// Purchase in place of Stripe. Mirrors `PaymentScreen`'s layout with a
/// single "Subscribe via Apple" action plus the App Store-mandated
/// "Restore Purchases" link. Drives the shared [PaymentController], which
/// resolves to `InAppPurchasePaymentService` on this platform.
class AppleIapCheckoutScreen extends ConsumerWidget {
  const AppleIapCheckoutScreen({super.key, required this.plan});

  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PaymentState>(paymentControllerProvider, (previous, next) {
      if (next.isSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) =>
                PaymentSuccessScreen(activationPending: next.activationPending),
          ),
        );
      } else if (next.isFailure) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? context.t('error.unknown')),
          ),
        );
        ref.read(paymentControllerProvider.notifier).dismissError();
      }
    });

    final paymentState = ref.watch(paymentControllerProvider);

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isDesktop || context.isTablet
                  ? 520
                  : double.infinity,
            ),
            child: Column(
              children: [
                _Header(title: context.t('iap.title')),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      context.sp(20),
                      context.sp(4),
                      context.sp(20),
                      context.sp(28),
                    ),
                    children: [
                      OrderSummaryCard(
                        planTitle: plan.title,
                        periodSuffix: plan.periodSuffix,
                        price: '\$${plan.price.toStringAsFixed(2)}',
                      ),
                      SizedBox(height: context.sp(24)),
                      SizedBox(
                        width: double.infinity,
                        height: context.sp(52),
                        child: ElevatedButton.icon(
                          onPressed: paymentState.isBusy
                              ? null
                              : () => ref
                                    .read(paymentControllerProvider.notifier)
                                    .purchaseViaStore(plan: plan),
                          icon: const Icon(Icons.apple),
                          label: paymentState.isBusy
                              ? SizedBox.square(
                                  dimension: context.sp(22),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(context.t('iap.buy_button')),
                        ),
                      ),
                      SizedBox(height: context.sp(16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: context.sp(14),
                            color: context.appTextSecondary,
                          ),
                          SizedBox(width: context.sp(6)),
                          Text(
                            context.t('iap.secure_note'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: context.sp(12),
                              color: context.appTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (paymentState.isActivating) ...[
                        SizedBox(height: context.sp(12)),
                        Text(
                          context.t('payment.activating'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: context.sp(13),
                            color: context.appTextSecondary,
                          ),
                        ),
                      ],
                      SizedBox(height: context.sp(20)),
                      Center(
                        child: TextButton(
                          onPressed: paymentState.isBusy
                              ? null
                              : () => ref
                                    .read(paymentControllerProvider.notifier)
                                    .restorePurchases(),
                          child: Text(
                            context.t('iap.restore_button'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: context.sp(13),
                              fontWeight: FontWeight.w700,
                              color: context.appPrimary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.sp(12),
        context.sp(10),
        context.sp(16),
        context.sp(6),
      ),
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
          SizedBox(width: context.sp(48)),
        ],
      ),
    );
  }
}
