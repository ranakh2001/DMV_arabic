/// Model for per-user notification preferences (stored in shared_preferences).
class NotificationSettings {
  const NotificationSettings({
    this.push = true,
    this.subscriptionReminders = true,
    this.contentUpdates = true,
    this.announcements = true,
    this.sound = true,
  });

  final bool push;
  final bool subscriptionReminders;
  final bool contentUpdates;
  final bool announcements;
  final bool sound;

  NotificationSettings copyWith({
    bool? push,
    bool? subscriptionReminders,
    bool? contentUpdates,
    bool? announcements,
    bool? sound,
  }) =>
      NotificationSettings(
        push: push ?? this.push,
        subscriptionReminders: subscriptionReminders ?? this.subscriptionReminders,
        contentUpdates: contentUpdates ?? this.contentUpdates,
        announcements: announcements ?? this.announcements,
        sound: sound ?? this.sound,
      );

  Map<String, bool> toMap() => {
        'notif_push': push,
        'notif_reminders': subscriptionReminders,
        'notif_content': contentUpdates,
        'notif_announcements': announcements,
        'notif_sound': sound,
      };

  factory NotificationSettings.fromMap(Map<String, bool?> map) =>
      NotificationSettings(
        push: map['notif_push'] ?? true,
        subscriptionReminders: map['notif_reminders'] ?? true,
        contentUpdates: map['notif_content'] ?? true,
        announcements: map['notif_announcements'] ?? true,
        sound: map['notif_sound'] ?? true,
      );
}
