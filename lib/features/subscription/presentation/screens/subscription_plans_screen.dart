import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock_subscription_plans.dart';
import '../../domain/entities/subscription_plan.dart';
import '../providers/subscription_provider.dart';
import '../widgets/auto_renew_switch_row.dart';
import '../widgets/plan_card.dart';
import '../widgets/secure_payment_badges_row.dart';
import '../widgets/trial_usage_card.dart';
import '../../../legal/presentation/screens/contact_us_screen.dart';
import '../../../payment/presentation/screens/payment_screen.dart';

/// The subscription paywall ("خطط الاشتراك"). Shown by [AuthGate] right
/// after login when the user has no active subscription, and reachable at
/// any time from the home screen's [SubscribeBanner]. All figures are mock
/// data — no billing API is wired up yet.
class SubscriptionPlansScreen extends ConsumerWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.isDesktop || context.isTablet ? 560 : double.infinity),
            child: Column(
              children: [
                _Header(onClose: () => _close(context, ref)),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(context.sp(20), context.sp(4), context.sp(20), context.sp(28)),
                    children: [
                      TrialUsageCard(
                        remaining: subscription.trialQuestionsRemaining,
                        total: subscription.trialQuestionsTotal,
                        progress: subscription.trialProgress,
                      ),
                      SizedBox(height: context.sp(28)),
                      Text(
                        context.t('subscription.unlock_title'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: context.sp(24),
                          fontWeight: FontWeight.w800,
                          color: context.appTextPrimary,
                        ),
                      ),
                      SizedBox(height: context.sp(8)),
                      Text(
                        context.t('subscription.unlock_subtitle'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: context.sp(14),
                          color: context.appTextSecondary,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: context.sp(26)),
                      for (final plan in mockSubscriptionPlans) ...[
                        PlanCard(
                          title: context.t(plan.titleKey),
                          price: '\$${plan.price.toStringAsFixed(2)}',
                          periodSuffix: context.t(plan.periodSuffixKey),
                          featureLabels: plan.featureKeys.map(context.t).toList(),
                          buttonLabel: context.t('subscription.choose_plan'),
                          highlighted: plan.isBestValue,
                          badgeLabel: plan.isBestValue ? context.t('subscription.best_value') : null,
                          onSelect: () => _selectPlan(context, ref, plan),
                        ),
                        SizedBox(height: context.sp(20)),
                      ],
                      AutoRenewSwitchRow(
                        value: subscription.autoRenew,
                        onChanged: (v) => ref.read(subscriptionProvider.notifier).setAutoRenew(v),
                      ),
                      SizedBox(height: context.sp(28)),
                      const SecurePaymentBadgesRow(),
                      SizedBox(height: context.sp(24)),
                      Center(
                        child: GestureDetector(
                          onTap: () => _showContact(context),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${context.t('subscription.contact_question')} ',
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: context.sp(13),
                                    color: context.appTextSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: context.t('subscription.contact_us'),
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: context.sp(13),
                                    fontWeight: FontWeight.w700,
                                    color: context.appPrimary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
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

  void _selectPlan(BuildContext context, WidgetRef ref, SubscriptionPlan plan) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PaymentScreen(plan: plan)),
    );
  }

  void _close(BuildContext context, WidgetRef ref) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      ref.read(paywallDismissedProvider.notifier).state = true;
    }
  }

  void _showContact(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ContactUsScreen()),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.sp(12), context.sp(10), context.sp(12), context.sp(6)),
      child: SizedBox(
        height: context.sp(40),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              context.t('subscription.title'),
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(18),
                fontWeight: FontWeight.w800,
                color: context.appTextPrimary,
              ),
            ),
            PositionedDirectional(
              end: 0,
              child: IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close_rounded, color: context.appTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
