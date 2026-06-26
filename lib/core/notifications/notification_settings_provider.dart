import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_providers.dart';
import 'notification_settings.dart';

/// Loads, updates, and persists [NotificationSettings] via shared_preferences.
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
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
