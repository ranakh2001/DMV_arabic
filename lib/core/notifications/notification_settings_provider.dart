import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_providers.dart';
import 'notification_service.dart';
import 'notification_service_provider.dart';
import 'notification_settings.dart';

/// FCM topic names mapped to each toggleable notification category.
class NotificationTopics {
  const NotificationTopics._();

  static const subscriptionReminders = 'subscription_reminders';
  static const contentUpdates = 'content_updates';
  static const announcements = 'announcements';
}

/// Loads, updates, and persists [NotificationSettings] via shared_preferences,
/// keeping FCM topic subscriptions in sync with the saved preferences.
class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    final prefs = ref.read(prefsServiceProvider);
    return NotificationSettings.fromMap({
      'notif_push': prefs.getBool('notif_push'),
      'notif_reminders': prefs.getBool('notif_reminders'),
      'notif_content': prefs.getBool('notif_content'),
      'notif_announcements': prefs.getBool('notif_announcements'),
      'notif_sound': prefs.getBool('notif_sound'),
    });
  }

  Future<void> update(NotificationSettings settings) async {
    state = settings;
    final prefs = ref.read(prefsServiceProvider);
    for (final entry in settings.toMap().entries) {
      await prefs.setBool(entry.key, entry.value);
    }
    await syncTopics();
  }

  Future<void> toggle({
    bool? push,
    bool? subscriptionReminders,
    bool? contentUpdates,
    bool? announcements,
    bool? sound,
  }) async {
    await update(
      state.copyWith(
        push: push != null ? !state.push : null,
        subscriptionReminders: subscriptionReminders != null ? !state.subscriptionReminders : null,
        contentUpdates: contentUpdates != null ? !state.contentUpdates : null,
        announcements: announcements != null ? !state.announcements : null,
        sound: sound != null ? !state.sound : null,
      ),
    );
  }

  /// Subscribes/unsubscribes FCM topics to match the current [state].
  /// The master `push` toggle overrides every individual category.
  Future<void> syncTopics() async {
    final service = ref.read(notificationServiceProvider);
    await _syncTopic(service, NotificationTopics.subscriptionReminders, state.push && state.subscriptionReminders);
    await _syncTopic(service, NotificationTopics.contentUpdates, state.push && state.contentUpdates);
    await _syncTopic(service, NotificationTopics.announcements, state.push && state.announcements);
  }

  Future<void> _syncTopic(NotificationService service, String topic, bool subscribed) {
    return subscribed ? service.subscribeToTopic(topic) : service.unsubscribeFromTopic(topic);
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
