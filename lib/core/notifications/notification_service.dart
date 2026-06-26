/// Interface for the push-notification vendor SDK.
/// Only the settings/state layer is implemented in this task.
/// Plug in a real SDK (FCM, APNs) under TODO(push).
abstract class NotificationService {
  /// Initialize the notification service (request permissions, configure channels).
  Future<void> initialize();

  /// Subscribe to a topic (e.g., 'announcements').
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic);
}

/// No-op stub. Replace with a real implementation in v2.
class StubNotificationService implements NotificationService {
  const StubNotificationService();

  @override
  Future<void> initialize() async {
    // TODO(push): Initialize FCM / APNs SDK.
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    // TODO(push): Subscribe to FCM topic.
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    // TODO(push): Unsubscribe from FCM topic.
  }
}
