import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../providers/home_tab_provider.dart';
import '../widgets/stats_empty_state.dart';
import '../widgets/tab_screen_header.dart';

/// The "إحصائياتي" (My Stats) tab. Shows an empty-state prompt until the
/// user has completed at least one simulation — no backend/API wired up yet.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

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
              TabScreenHeader(title: context.t('stats.title')),
              SizedBox(height: context.sp(20)),
              StatsEmptyState(
                onStartTap: () => ref.read(homeTabProvider.notifier).select(HomeTab.simulation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
