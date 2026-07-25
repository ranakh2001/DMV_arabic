import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../subscription/domain/entities/subscription_plan.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../domain/entities/payment_method.dart';
import '../providers/payment_provider.dart';
import '../widgets/card_details_form.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/payment_method_tile.dart';
import 'payment_success_screen.dart';

/// Checkout step for a chosen [SubscriptionPlan]: pick a (mock) payment
/// rail, optionally enter card details, then confirm. No payment gateway
/// is called — [PaymentController.pay] simulates the round trip.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.plan});

  final SubscriptionPlan plan;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  PaymentMethodType _selectedMethod = PaymentMethodType.card;

  @override
  void dispose() {
    _holderCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentControllerProvider);
    final autoRenew = ref.watch(subscriptionProvider.select((s) => s.autoRenew));

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.isDesktop || context.isTablet ? 520 : double.infinity),
            child: Column(
              children: [
                _Header(title: context.t('payment.title')),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(context.sp(20), context.sp(4), context.sp(20), context.sp(28)),
                      children: [
                        OrderSummaryCard(
                          planTitle: context.t(widget.plan.titleKey),
                          periodSuffix: context.t(widget.plan.periodSuffixKey),
                          price: '\$${widget.plan.price.toStringAsFixed(2)}',
                        ),
                        SizedBox(height: context.sp(24)),
                        Text(
                          context.t('payment.method_title'),
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: context.sp(15),
                            fontWeight: FontWeight.w700,
                            color: context.appTextPrimary,
                          ),
                        ),
                        SizedBox(height: context.sp(12)),
                        for (final type in PaymentMethodType.values) ...[
                          PaymentMethodTile(
                            type: type,
                            selected: _selectedMethod == type,
                            onTap: () => setState(() => _selectedMethod = type),
                          ),
                          SizedBox(height: context.sp(10)),
                        ],
                        if (_selectedMethod == PaymentMethodType.card) ...[
                          SizedBox(height: context.sp(8)),
                          CardDetailsForm(
                            holderController: _holderCtrl,
                            numberController: _numberCtrl,
                            expiryController: _expiryCtrl,
                            cvvController: _cvvCtrl,
                          ),
                        ],
                        SizedBox(height: context.sp(20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline_rounded, size: context.sp(14), color: context.appTextSecondary),
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
                        SizedBox(height: context.sp(20)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: paymentState.isProcessing ? null : () => _pay(autoRenew),
                            child: paymentState.isProcessing
                                ? SizedBox.square(
                                    dimension: context.sp(22),
                                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    context.ts('payment.pay_now', {
                                      'price': '\$${widget.plan.price.toStringAsFixed(2)}',
                                    }),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pay(bool autoRenew) async {
    if (_selectedMethod == PaymentMethodType.card &&
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref.read(paymentControllerProvider.notifier).pay(plan: widget.plan, autoRenew: autoRenew);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const PaymentSuccessScreen()),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.sp(12), context.sp(10), context.sp(16), context.sp(6)),
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
