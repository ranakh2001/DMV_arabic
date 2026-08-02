import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_card.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/entities/subscription_plan.dart';
import '../providers/subscription_packages_providers.dart';
import '../providers/subscription_provider.dart';
import '../widgets/auto_renew_switch_row.dart';
import '../widgets/plan_card.dart';
import '../widgets/secure_payment_badges_row.dart';
import '../widgets/trial_usage_card.dart';
import '../../../legal/presentation/screens/contact_us_screen.dart';
import '../../../payment/presentation/screens/payment_screen.dart';

/// The subscription paywall ("خطط الاشتراك"). Shown by [AuthGate] right
/// after login when the user has no active subscription, and reachable at
/// any time from the home screen's [SubscribeBanner]. Plan cards are backed
/// by `GET /subscription-packages` — see [subscriptionPackagesProvider].
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  @override
  void initState() {
    super.initState();
    // Fetches the free-questions-used count shown in [TrialUsageCard] below.
    Future.microtask(() => ref.read(profileControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);
    final freeQuestionsUsed = ref.watch(
      profileControllerProvider.select((s) => s.profile?.freeQuestionsUsed),
    );
    final trialUsed = freeQuestionsUsed ?? subscription.trialQuestionsUsed;
    final trialTotal = subscription.trialQuestionsTotal;
    final trialRemaining = (trialTotal - trialUsed).clamp(0, trialTotal);
    final trialProgress = trialTotal == 0 ? 0.0 : trialUsed / trialTotal;

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isDesktop || context.isTablet
                  ? 560
                  : double.infinity,
            ),
            child: Column(
              children: [
                _Header(onClose: () => _close(context, ref)),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _refresh(ref),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        context.sp(20),
                        context.sp(4),
                        context.sp(20),
                        context.sp(28),
                      ),
                      children: [
                        TrialUsageCard(
                          remaining: trialRemaining,
                          total: trialTotal,
                          progress: trialProgress,
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
                        ...ref
                            .watch(subscriptionPackagesProvider)
                            .when<List<Widget>>(
                              data: (packages) => [
                                for (final plan in _toPlans(
                                  context,
                                  packages,
                                )) ...[
                                  PlanCard(
                                    title: plan.title,
                                    price: '\$${plan.price.toStringAsFixed(2)}',
                                    periodSuffix: plan.periodSuffix,
                                    featureLabels: plan.featureLabels,
                                    buttonLabel: context.t(
                                      'subscription.choose_plan',
                                    ),
                                    highlighted: plan.isBestValue,
                                    badgeLabel: plan.isBestValue
                                        ? context.t('subscription.best_value')
                                        : null,
                                    onSelect: () =>
                                        _selectPlan(context, ref, plan),
                                  ),
                                  SizedBox(height: context.sp(20)),
                                ],
                              ],
                              loading: () => [
                                const SkeletonCardList(count: 2, height: 180),
                                SizedBox(height: context.sp(20)),
                              ],
                              error: (error, _) => [
                                _PackagesLoadError(
                                  onRetry: () => ref.invalidate(
                                    subscriptionPackagesProvider,
                                  ),
                                ),
                                SizedBox(height: context.sp(20)),
                              ],
                            ),
                        AutoRenewSwitchRow(
                          value: subscription.autoRenew,
                          onChanged: (v) => ref
                              .read(subscriptionProvider.notifier)
                              .setAutoRenew(v),
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
                                    text:
                                        '${context.t('subscription.contact_question')} ',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(subscriptionPackagesProvider.future),
      ref.read(profileControllerProvider.notifier).load(),
    ]);
  }

  /// Resolves each package's locale-aware display text and flags the one
  /// with the lowest price-per-day as best value.
  List<SubscriptionPlan> _toPlans(
    BuildContext context,
    List<SubscriptionPackage> packages,
  ) {
    if (packages.isEmpty) return const [];
    final isAr = context.isRtl;
    final cheapestPerDay = packages
        .map((p) => p.pricePerDay)
        .reduce((a, b) => a < b ? a : b);
    return packages
        .map(
          (p) => SubscriptionPlan(
            id: p.id,
            title: p.name(arabic: isAr),
            periodSuffix: isAr
                ? '/ ${p.durationDays} يوم'
                : '/ ${p.durationDays} days',
            price: p.priceUsd,
            featureLabels: p.features,
            isBestValue: p.pricePerDay == cheapestPerDay,
          ),
        )
        .toList();
  }

  void _selectPlan(BuildContext context, WidgetRef ref, SubscriptionPlan plan) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => PaymentScreen(plan: plan)));
  }

  void _close(BuildContext context, WidgetRef ref) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      ref.read(paywallDismissedProvider.notifier).state = true;
    }
  }

  void _showContact(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ContactUsScreen()));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.sp(12),
        context.sp(10),
        context.sp(12),
        context.sp(6),
      ),
      child: SizedBox(
        height: context.sp(40),
        child: Row(
          children: [
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close_rounded, color: context.appTextPrimary),
            ),
            Expanded(
              child: Center(
                child: Text(
                  context.t('subscription.title'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.w800,
                    color: context.appTextPrimary,
                  ),
                ),
              ),
            ),
            const IgnorePointer(
              child: Opacity(
                opacity: 0,
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.close_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackagesLoadError extends StatelessWidget {
  const _PackagesLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.sp(24)),
      child: Column(
        children: [
          Text(
            context.isRtl
                ? 'تعذر جلب باقات الاشتراك.'
                : 'Failed to load subscription packages.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              color: context.appTextSecondary,
            ),
          ),
          SizedBox(height: context.sp(12)),
          TextButton(
            onPressed: onRetry,
            child: Text(context.isRtl ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    );
  }
}
