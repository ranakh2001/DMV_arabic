/// Whether the signed-in user has push notifications enabled (stored in
/// shared_preferences).
class NotificationSettings {
  const NotificationSettings({this.push = true});

  final bool push;

  NotificationSettings copyWith({bool? push}) =>
      NotificationSettings(push: push ?? this.push);
}
