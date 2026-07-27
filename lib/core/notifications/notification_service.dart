import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Interface for the push-notification vendor SDK.
abstract class NotificationService {
  /// Initialize the notification service (request permissions, configure channels).
  Future<void> initialize();

  /// Subscribe to a topic (e.g., 'announcements').
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic);

  /// The FCM registration token for this device, if available.
  Future<String?> getToken();
}

/// Must be a top-level (or static) function: the platform relaunches the
/// engine in a background isolate to invoke it, so it can't close over
/// instance state.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // TODO(push): Hand off to local storage / analytics once backend is ready.
  debugPrint('[FCM][background] ${message.messageId}: ${message.notification?.title}');
}

/// FCM-backed implementation of [NotificationService].
class FcmNotificationService implements NotificationService {
  FcmNotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM][foreground] ${message.messageId}: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM][opened] ${message.messageId}: ${message.notification?.title}');
    });
  }

  @override
  Future<void> subscribeToTopic(String topic) => _messaging.subscribeToTopic(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) => _messaging.unsubscribeFromTopic(topic);

  @override
  Future<String?> getToken() => _messaging.getToken();
}
