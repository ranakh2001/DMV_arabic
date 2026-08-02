import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_providers.dart';
import '../storage/storage_providers.dart';
import 'fcm_token_remote_data_source.dart';
import 'notification_service_provider.dart';
import 'notification_settings.dart';

final fcmTokenRemoteDataSourceProvider = Provider<FcmTokenRemoteDataSource>(
  (ref) => FcmTokenRemoteDataSource(ref.watch(dioProvider)),
);

/// FCM topics subscribed to while push notifications are enabled.
class NotificationTopics {
  const NotificationTopics._();

  static const subscriptionReminders = 'subscription_reminders';
  static const contentUpdates = 'content_updates';
  static const announcements = 'announcements';

  static const all = [subscriptionReminders, contentUpdates, announcements];
}

/// Loads, updates, and persists the push-notification permission toggle via
/// shared_preferences, keeping FCM topic subscriptions in sync.
class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    final prefs = ref.read(prefsServiceProvider);
    return NotificationSettings(push: prefs.getBool('notif_push') ?? true);
  }

  Future<void> update(NotificationSettings settings) async {
    state = settings;
    final prefs = ref.read(prefsServiceProvider);
    await prefs.setBool('notif_push', settings.push);
    await syncTopics();
  }

  /// Subscribes/unsubscribes every FCM topic to match [state.push].
  Future<void> syncTopics() async {
    final service = ref.read(notificationServiceProvider);
    for (final topic in NotificationTopics.all) {
      await (state.push
          ? service.subscribeToTopic(topic)
          : service.unsubscribeFromTopic(topic));
    }
  }

  /// Registers this device's FCM token with the backend, skipping the call
  /// if it's already been registered (same token as last successful sync).
  Future<void> registerDeviceToken() async {
    try {
      final token = await ref.read(notificationServiceProvider).getToken();
      if (token == null) return;

      final prefs = ref.read(prefsServiceProvider);
      if (prefs.syncedFcmToken == token) return;

      await ref.read(fcmTokenRemoteDataSourceProvider).register(token);
      await prefs.setSyncedFcmToken(token);
    } catch (e) {
      // Best-effort: push setup must not fail login/app startup.
      debugPrint('[fcm-token] register failed: $e');
    }
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );
