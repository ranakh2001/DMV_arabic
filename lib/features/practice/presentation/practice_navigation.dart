import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../subscription/presentation/providers/subscription_provider.dart';
import 'providers/free_trial_provider.dart';
import 'screens/practice_question_screen.dart';
import 'screens/trial_ended_screen.dart';

/// Entry point for the free 10-random-questions Quick Test (FR-16, BR-01),
/// shared by the home tab's Quick Test card and the Simulation tab's Free
/// Trial button. Available to subscribed and unsubscribed users alike (BR-03
/// only exempts subscribed users from the quota, not from the feature).
///
/// - Subscribed users always go straight to the practice screen — the quota
///   never applies to them (see `FreeTrialController.syncFromCheckAnswer`).
/// - Unsubscribed users with quota left go straight to the practice screen.
/// - Unsubscribed users with no quota left never hit the API — they see the
///   trial-ended paywall immediately.
void startFreeTrial(BuildContext context, WidgetRef ref) {
  final isSubscribed = ref.read(subscriptionProvider).isSubscribed;
  if (!isSubscribed && ref.read(freeTrialProvider).isExhausted) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TrialEndedScreen()));
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const PracticeQuestionScreen()),
  );
}
