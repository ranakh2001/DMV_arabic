import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../home/presentation/widgets/home_background.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notifications_providers.dart';

/// "الإشعارات" — reached from the bell icon on Home. Lists the signed-in
/// user's notifications from `GET /notifications`.
class NotificationsListScreen extends ConsumerWidget {
  const NotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

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
                        maxWidth: context.isDesktop || context.isTablet
                            ? 520
                            : double.infinity,
                      ),
                      child: notificationsAsync.when(
                        data: (notifications) =>
                            _NotificationsList(notifications: notifications),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => _NotificationsError(
                          onRetry: () => ref.invalidate(notificationsProvider),
                        ),
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

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.notifications});

  final List<AppNotification> notifications;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
          child: Text(
            context.t('notifications.empty'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: context.sp(14),
              color: context.appTextSecondary,
            ),
          ),
        ),
      );
    }

    final isAr = context.isRtl;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.sp(20),
        context.sp(8),
        context.sp(20),
        context.sp(24),
      ),
      children: [
        for (var i = 0; i < notifications.length; i++) ...[
          _NotificationTile(notification: notifications[i], isAr: isAr),
          if (i != notifications.length - 1) SizedBox(height: context.sp(10)),
        ],
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.isAr});

  final AppNotification notification;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.readStatus;

    return Container(
      padding: EdgeInsets.all(context.sp(14)),
      decoration: BoxDecoration(
        color: context.appGlassTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unread
              ? context.appPrimary.withAlpha(90)
              : context.appGlassBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.sp(40),
            height: context.sp(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.appPrimary.withAlpha(32),
            ),
            child: Icon(
              _iconFor(notification.type),
              color: context.appPrimary,
              size: context.sp(20),
            ),
          ),
          SizedBox(width: context.sp(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title(arabic: isAr),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w700,
                    color: context.appTextPrimary,
                  ),
                ),
                SizedBox(height: context.sp(4)),
                Text(
                  notification.message(arabic: isAr),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(13),
                    color: context.appTextSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: context.sp(6)),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: context.sp(11.5),
                    color: context.appTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (unread) ...[
            SizedBox(width: context.sp(8)),
            Container(
              width: context.sp(9),
              height: context.sp(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.appPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
    'announcement' => Icons.campaign_rounded,
    _ => Icons.notifications_active_rounded,
  };

  String _formatDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year} ${pad(date.hour)}:${pad(date.minute)}';
  }
}

class _NotificationsError extends StatelessWidget {
  const _NotificationsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t('notifications.error'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: context.sp(13),
                color: context.appTextSecondary,
              ),
            ),
            SizedBox(height: context.sp(8)),
            TextButton(
              onPressed: onRetry,
              child: Text(context.t('common.retry')),
            ),
          ],
        ),
      ),
    );
  }
}
