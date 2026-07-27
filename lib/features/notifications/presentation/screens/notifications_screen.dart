import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/notifications/notification_settings_provider.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glass.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../widgets/notification_toggle_row.dart';

/// "الإشعارات" — reached from the bell icon on Home. Toggles here update
/// [notificationSettingsProvider], which persists the choice locally and
/// subscribes/unsubscribes the matching FCM topic.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          const HomeBackground(),
          SafeArea(
            child: Column(
              children: [
                AppScreenHeader(title: context.t('notifications.title')),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.isDesktop || context.isTablet ? 520 : double.infinity,
                      ),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(context.sp(20), context.sp(8), context.sp(20), context.sp(24)),
                        children: [
                          Text(
                            context.t('notifications.subtitle'),
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: context.sp(13),
                              color: context.appTextSecondary,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: context.sp(20)),
                          GlassContainer(
                            radius: 20,
                            child: NotificationToggleRow(
                              icon: Icons.notifications_active_rounded,
                              label: context.t('notif.push'),
                              value: settings.push,
                              onChanged: (v) => notifier.update(settings.copyWith(push: v)),
                            ),
                          ),
                          SizedBox(height: context.sp(16)),
                          GlassContainer(
                            radius: 20,
                            child: Column(
                              children: [
                                NotificationToggleRow(
                                  icon: Icons.autorenew_rounded,
                                  label: context.t('notif.reminders'),
                                  value: settings.subscriptionReminders,
                                  onChanged: settings.push
                                      ? (v) => notifier.update(settings.copyWith(subscriptionReminders: v))
                                      : null,
                                ),
                                Divider(height: 1, color: context.appGlassBorder),
                                NotificationToggleRow(
                                  icon: Icons.menu_book_rounded,
                                  label: context.t('notif.content'),
                                  value: settings.contentUpdates,
                                  onChanged: settings.push
                                      ? (v) => notifier.update(settings.copyWith(contentUpdates: v))
                                      : null,
                                ),
                                Divider(height: 1, color: context.appGlassBorder),
                                NotificationToggleRow(
                                  icon: Icons.campaign_rounded,
                                  label: context.t('notif.announcements'),
                                  value: settings.announcements,
                                  onChanged: settings.push
                                      ? (v) => notifier.update(settings.copyWith(announcements: v))
                                      : null,
                                ),
                                Divider(height: 1, color: context.appGlassBorder),
                                NotificationToggleRow(
                                  icon: Icons.volume_up_rounded,
                                  label: context.t('notif.sound'),
                                  value: settings.sound,
                                  onChanged: settings.push
                                      ? (v) => notifier.update(settings.copyWith(sound: v))
                                      : null,
                                ),
                              ],
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
    );
  }
}
