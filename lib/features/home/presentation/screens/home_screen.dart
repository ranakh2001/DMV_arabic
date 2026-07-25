import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_controller_provider.dart';
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

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.isDesktop || context.isTablet ? 520 : double.infinity),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              context.sp(20),
              context.sp(16),
              context.sp(20),
              context.sp(24),
            ),
            children: [
              HomeTopBar(
                onAvatarTap: () => ref.read(homeTabProvider.notifier).select(HomeTab.profile),
                onNotificationsTap: () => _showComingSoon(context, context.t('home.no_notifications')),
              ),
              SizedBox(height: context.sp(20)),
              WelcomeProgressCard(userName: userName, progress: 0.62),
              SizedBox(height: context.sp(16)),
              SubscribeBanner(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SubscriptionPlansScreen()),
                ),
              ),
              SizedBox(height: context.sp(16)),
              Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.bolt_rounded,
                      label: context.t('home.quick_test_card'),
                      onTap: () => _showComingSoon(context),
                    ),
                  ),
                  SizedBox(width: context.sp(14)),
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.bar_chart_rounded,
                      label: context.t('home.stats_card'),
                      onTap: () => ref.read(homeTabProvider.notifier).select(HomeTab.stats),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.sp(24)),
              SectionHeader(
                title: context.t('home.continue_section_title'),
                actionLabel: context.t('home.view_all'),
                onActionTap: () => _showComingSoon(context),
              ),
              SizedBox(height: context.sp(12)),
              ContinueTestCard(
                title: context.t('home.simulation_test_title'),
                answered: 23,
                total: 46,
                onTap: () => _showComingSoon(context),
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
              QuickQuizCard(onStart: () => _showComingSoon(context)),
            ],
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
