import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../exam/presentation/providers/exam_controller.dart';
import '../../../exam/presentation/screens/exam_question_screen.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/screens/subscription_plans_screen.dart';
import '../providers/home_tab_provider.dart';
import '../widgets/info_note_row.dart';
import '../widgets/simulation_hero_card.dart';
import '../widgets/tab_screen_header.dart';
import '../widgets/test_details_card.dart';

/// The "المحاكاة" (Simulation) tab: lets the user review the test's rules
/// before starting a full simulation run.
class SimulationScreen extends ConsumerWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.isDesktop || context.isTablet ? 520 : double.infinity),
          child: ListView(
            padding: EdgeInsets.fromLTRB(context.sp(20), context.sp(16), context.sp(20), context.sp(24)),
            children: [
              TabScreenHeader(title: context.t('simulation.title')),
              SizedBox(height: context.sp(20)),
              const SimulationHeroCard(),
              SizedBox(height: context.sp(16)),
              const TestDetailsCard(
                questionCount: AppConstants.examQuestionCount,
                minPassCount: AppConstants.examMinPassCount,
              ),
              SizedBox(height: context.sp(16)),
              InfoNoteRow(icon: Icons.cloud_done_outlined, text: context.t('simulation.autosave_note')),
              InfoNoteRow(icon: Icons.edit_note_rounded, text: context.t('simulation.review_note')),
              SizedBox(height: context.sp(20)),
              ElevatedButton.icon(
                onPressed: () => _startSimulation(context, ref),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(context.t('simulation.start')),
              ),
              SizedBox(height: context.sp(12)),
              Center(
                child: TextButton(
                  onPressed: () => ref.read(homeTabProvider.notifier).select(HomeTab.home),
                  child: Text(context.t('common.cancel')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startSimulation(BuildContext context, WidgetRef ref) {
    final subscription = ref.read(subscriptionProvider);
    if (!subscription.isSubscribed && subscription.trialQuestionsRemaining == 0) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SubscriptionPlansScreen()));
      return;
    }
    ref.read(examControllerProvider.notifier).restart();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ExamQuestionScreen()));
  }
}
