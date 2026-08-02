import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../subscription/domain/entities/subscription_plan.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/custom_card_form.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/platform_pay_button.dart';
import 'payment_success_screen.dart';

/// Checkout step for a chosen [SubscriptionPlan]. Card entry is our own
/// themed [CustomCardForm] (backed by Stripe's [CardFormField]), with a
/// native Apple Pay / Google Pay button offered above it as a shortcut — see
/// [PaymentPlatformPayButton]. No Stripe-branded `PaymentSheet` is shown.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.plan});

  final SubscriptionPlan plan;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _cardController = CardFormEditController();
  bool _cardComplete = false;
  bool _cardExpanded = false;

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final autoRenew = ref.watch(
      subscriptionProvider.select((s) => s.autoRenew),
    );

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
                _Header(title: context.t('payment.title')),
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
                        planTitle: widget.plan.title,
                        periodSuffix: widget.plan.periodSuffix,
                        price: '\$${widget.plan.price.toStringAsFixed(2)}',
                      ),
                      SizedBox(height: context.sp(24)),
                      PaymentPlatformPayButton(
                        onPay: paymentState.isBusy
                            ? () {}
                            : () => ref
                                  .read(paymentControllerProvider.notifier)
                                  .payWithPlatformPay(
                                    plan: widget.plan,
                                    autoRenew: autoRenew,
                                  ),
                      ),
                      _OrDivider(label: context.t('payment.divider_or')),
                      SizedBox(height: context.sp(16)),
                      _CardMethodTile(
                        expanded: _cardExpanded,
                        onTap: () =>
                            setState(() => _cardExpanded = !_cardExpanded),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: _cardExpanded
                            ? Padding(
                                padding: EdgeInsets.only(top: context.sp(12)),
                                child: CustomCardForm(
                                  controller: _cardController,
                                  onCardChanged: (details) => setState(
                                    () => _cardComplete =
                                        details?.complete ?? false,
                                  ),
                                ),
                              )
                            : const SizedBox(width: double.infinity),
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
                            context.t('payment.secure_note'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: context.sp(12),
                              color: context.appTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (_cardExpanded) ...[
                        SizedBox(height: context.sp(20)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: paymentState.isBusy || !_cardComplete
                                ? null
                                : () => ref
                                      .read(paymentControllerProvider.notifier)
                                      .payWithCard(
                                        plan: widget.plan,
                                        autoRenew: autoRenew,
                                      ),
                            child: paymentState.isBusy
                                ? SizedBox.square(
                                    dimension: context.sp(22),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    context.ts('payment.pay_now', {
                                      'price':
                                          '\$${widget.plan.price.toStringAsFixed(2)}',
                                    }),
                                  ),
                          ),
                        ),
                      ],
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

/// Tappable row for the "Credit / Debit Card" method. Doesn't carry any
/// card state itself — just toggles whether [CustomCardForm] (the actual
/// Visa/Mastercard entry fields) is expanded below it, so the form isn't
/// mounted (and doesn't show as an empty box) until the user opts into it.
class _CardMethodTile extends StatelessWidget {
  const _CardMethodTile({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(16),
          vertical: context.sp(14),
        ),
        decoration: BoxDecoration(
          color: expanded ? accent.withAlpha(24) : context.appSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: expanded ? accent : context.appGlassBorder,
            width: expanded ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.credit_card_rounded,
              size: context.sp(20),
              color: context.appTextPrimary,
            ),
            SizedBox(width: context.sp(10)),
            Expanded(
              child: Text(
                context.t('payment.method.card'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.w600,
                  color: context.appTextPrimary,
                ),
              ),
            ),
            AnimatedRotation(
              duration: const Duration(milliseconds: 150),
              turns: expanded ? 0.5 : 0,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: context.sp(22),
                color: context.appTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(4)),
      child: Row(
        children: [
          Expanded(child: Divider(color: context.appGlassBorder)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(12),
                fontWeight: FontWeight.w700,
                color: context.appTextSecondary,
              ),
            ),
          ),
          Expanded(child: Divider(color: context.appGlassBorder)),
        ],
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
