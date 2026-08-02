import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../subscription/presentation/screens/subscription_plans_screen.dart';
import '../providers/free_trial_provider.dart';

/// Shown once the free-trial question quota is exhausted (FR-22). The only
/// way forward from here is subscribing — back navigation to the Practice
/// question screen is intentionally not offered.
class TrialEndedScreen extends ConsumerWidget {
  const TrialEndedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final freeTrial = ref.watch(freeTrialProvider);

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.sp(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: context.sp(72),
                  height: context.sp(72),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appPrimary.withAlpha(30),
                  ),
                  child: Icon(
                    Icons.lock_clock_rounded,
                    color: context.appPrimary,
                    size: context.sp(36),
                  ),
                ),
                SizedBox(height: context.sp(20)),
                Text(
                  context.t('practice.trial_ended_title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.w800,
                    color: context.appTextPrimary,
                  ),
                ),
                SizedBox(height: context.sp(10)),
                Text(
                  context.ts('practice.trial_ended_message', {
                    'used': '${freeTrial.used}',
                    'total': '${freeTrial.max}',
                  }),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(14),
                    color: context.appTextSecondary,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: context.sp(28)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(0, context.sp(52)),
                    ),
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const SubscriptionPlansScreen(),
                      ),
                    ),
                    child: Text(context.t('practice.subscribe_now')),
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
