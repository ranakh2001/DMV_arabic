import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../practice/presentation/practice_navigation.dart';
import '../../../simulation_exam/domain/entities/exam_summary.dart';
import '../../../simulation_exam/presentation/providers/exam_attempt_controller.dart';
import '../../../simulation_exam/presentation/providers/simulation_exam_providers.dart';
import '../../../simulation_exam/presentation/screens/exam_attempt_screen.dart';
import '../../../simulation_exam/presentation/widgets/exam_history_section.dart';
import '../../../simulation_exam/presentation/widgets/exam_list.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/screens/subscription_plans_screen.dart';
import '../widgets/info_note_row.dart';
import '../widgets/simulation_hero_card.dart';
import '../widgets/tab_screen_header.dart';

/// The "المحاكاة" (Simulation) tab: lets the user review the test's rules,
/// start a live API-backed simulation run, and review past attempts.
class SimulationScreen extends ConsumerWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateId = ref.watch(prefsServiceProvider).selectedStateId;

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isDesktop || context.isTablet
                ? 520
                : double.infinity,
          ),
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref, stateId),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                context.sp(20),
                context.sp(16),
                context.sp(20),
                context.sp(24),
              ),
              children: [
                TabScreenHeader(title: context.t('simulation.title')),
                SizedBox(height: context.sp(20)),
                const SimulationHeroCard(),
                SizedBox(height: context.sp(16)),
                OutlinedButton.icon(
                  onPressed: () => startFreeTrial(context, ref),
                  icon: const Icon(Icons.bolt_rounded),
                  label: Text(context.t('simulation.free_trial_button')),
                ),
                SizedBox(height: context.sp(16)),
                InfoNoteRow(
                  icon: Icons.cloud_done_outlined,
                  text: context.t('simulation.autosave_note'),
                ),
                InfoNoteRow(
                  icon: Icons.edit_note_rounded,
                  text: context.t('simulation.review_note'),
                ),
                SizedBox(height: context.sp(20)),
                if (stateId == null)
                  _SelectStateNotice(text: context.t('exam.select_state_first'))
                else
                  ExamListSection(
                    stateId: stateId,
                    onSelected: (exam) => _onExamSelected(context, ref, exam),
                  ),
                SizedBox(height: context.sp(24)),
                Text(
                  context.t('exam.history_title'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                  ),
                ),
                SizedBox(height: context.sp(12)),
                const ExamHistorySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref, int? stateId) async {
    await Future.wait([
      if (stateId != null) ref.refresh(simulationExamsProvider(stateId).future),
      ref.refresh(examHistoryProvider.future),
    ]);
  }

  void _onExamSelected(BuildContext context, WidgetRef ref, ExamSummary exam) {
    final subscription = ref.read(subscriptionProvider);
    if (!subscription.isSubscribed &&
        subscription.trialQuestionsRemaining == 0) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SubscriptionPlansScreen(),
        ),
      );
      return;
    }
    _beginAttempt(context, ref, exam);
  }

  Future<void> _beginAttempt(
    BuildContext context,
    WidgetRef ref,
    ExamSummary exam,
  ) async {
    final started = await ref
        .read(examAttemptControllerProvider.notifier)
        .start(examId: exam.id);
    if (!context.mounted) return;
    if (started) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ExamAttemptScreen()),
      );
      return;
    }
    final error = ref.read(examAttemptControllerProvider).error;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? context.t('exam.start_error'))),
    );
  }
}

class _SelectStateNotice extends StatelessWidget {
  const _SelectStateNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.sp(16)),
      decoration: BoxDecoration(
        color: context.appGlassTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appGlassBorder),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: context.sp(13),
          color: context.appTextSecondary,
        ),
      ),
    );
  }
}
