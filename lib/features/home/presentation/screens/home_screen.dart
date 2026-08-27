import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import '../../../auth/presentation/providers/auth_controller_provider.dart';
import '../../../exam/presentation/providers/exam_controller.dart';
import '../../../notifications/presentation/screens/notifications_list_screen.dart';
import '../../../practice/presentation/practice_navigation.dart';
import '../../../subscription/presentation/screens/subscription_plans_screen.dart';
import '../providers/home_tab_provider.dart';
import '../widgets/continue_test_card.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/quick_quiz_card.dart';
import '../widgets/section_header.dart';
import '../widgets/subscribe_banner.dart';
import '../widgets/welcome_progress_card.dart';

/// The "الرئيسية" (Home) tab content. Purely presentational for now — all
/// figures are static mock data until the backend/API is wired up.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userName = authState.user?.name ?? '';
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final progress = ((summaryAsync.valueOrNull?.correctRatio ?? 0.0) / 100)
        .clamp(0.0, 1.0);
    final examState = ref.watch(examControllerProvider);
    final hasProgress = examState.answeredCount > 0;
    final selectedState = ref.watch(prefsServiceProvider).selectedState;
    final simulationTestTitle = selectedState == null
        ? context.t('home.simulation_test_title')
        : context.ts('home.simulation_test_title_named', {
            'state': selectedState,
          });

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
            onRefresh: () =>
                Future.wait([ref.refresh(analyticsSummaryProvider.future)]),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                context.sp(20),
                context.sp(16),
                context.sp(20),
                context.sp(24),
              ),
              children: [
                HomeTopBar(
                  onAvatarTap: () => ref
                      .read(homeTabProvider.notifier)
                      .select(HomeTab.profile),
                  onNotificationsTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationsListScreen(),
                    ),
                  ),
                ),
                SizedBox(height: context.sp(20)),
                WelcomeProgressCard(userName: userName, progress: progress),
                SizedBox(height: context.sp(16)),
                SubscribeBanner(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SubscriptionPlansScreen(),
                    ),
                  ),
                ),
                SizedBox(height: context.sp(16)),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionCard(
                        icon: Icons.bolt_rounded,
                        label: context.t('home.quick_test_card'),
                        onTap: () => ref
                            .read(homeTabProvider.notifier)
                            .select(HomeTab.simulation),
                      ),
                    ),
                    SizedBox(width: context.sp(14)),
                    Expanded(
                      child: QuickActionCard(
                        icon: Icons.bar_chart_rounded,
                        label: context.t('home.stats_card'),
                        onTap: () => ref
                            .read(homeTabProvider.notifier)
                            .select(HomeTab.stats),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.sp(24)),
                SectionHeader(
                  title: context.t(
                    hasProgress
                        ? 'home.continue_section_title'
                        : 'home.start_first_simulation_title',
                  ),
                  actionLabel: hasProgress ? context.t('home.view_all') : null,
                  onActionTap: hasProgress
                      ? () => _showComingSoon(context)
                      : null,
                ),
                SizedBox(height: context.sp(12)),
                ContinueTestCard(
                  title: simulationTestTitle,
                  answered: examState.answeredCount,
                  total: AppConstants.examQuestionCount,
                  onTap: hasProgress
                      ? () => _showComingSoon(context)
                      : () => ref
                            .read(homeTabProvider.notifier)
                            .select(HomeTab.simulation),
                ),
                SizedBox(height: context.sp(20)),
                Text(
                  context.t('home.quick_test_card'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(17),
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                  ),
                ),
                SizedBox(height: context.sp(12)),
                QuickQuizCard(onStart: () => startFreeTrial(context, ref)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, [String? message]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? context.t('home.coming_soon'))),
    );
  }
}
