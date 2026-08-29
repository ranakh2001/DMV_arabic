import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  
  debugPrint('========================================');
  debugPrint('[FCM][background] messageId: ${message.messageId}');
  debugPrint('[FCM][background] title: ${message.notification?.title}');
  debugPrint('[FCM][background] body: ${message.notification?.body}');
  debugPrint('[FCM][background] data: ${message.data}');
  debugPrint('========================================');
}

/// Android channel used to display FCM notifications while the app is in
/// the foreground (Android never shows these on its own — only background/
/// terminated messages are auto-displayed by the OS).
const _androidNotificationChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'Notifications',
  description: 'Used for important notifications.',
  importance: Importance.max,
);

/// FCM-backed implementation of [NotificationService].
class FcmNotificationService implements NotificationService {
  FcmNotificationService({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidNotificationChannel);

    final token = await _messaging.getToken();
    debugPrint('========================================');
    debugPrint('[FCM] TOKEN: $token');
    debugPrint('========================================');

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('========================================');
      debugPrint('[FCM][foreground] messageId: ${message.messageId}');
      debugPrint('[FCM][foreground] title: ${message.notification?.title}');
      debugPrint('[FCM][foreground] body: ${message.notification?.body}');
      debugPrint('[FCM][foreground] data: ${message.data}');
      debugPrint('========================================');

      final notification = message.notification;
      if (notification == null) return;

      // Android doesn't auto-display notifications while the app is in the
      // foreground, so we surface it manually via a local notification.
      // iOS handles this itself via setForegroundNotificationPresentationOptions.
      if (defaultTargetPlatform == TargetPlatform.android) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _androidNotificationChannel.id,
              _androidNotificationChannel.name,
              channelDescription: _androidNotificationChannel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('========================================');
      debugPrint('[FCM][opened] messageId: ${message.messageId}');
      debugPrint('[FCM][opened] title: ${message.notification?.title}');
      debugPrint('[FCM][opened] body: ${message.notification?.body}');
      debugPrint('[FCM][opened] data: ${message.data}');
      debugPrint('========================================');
    });
  }

  @override
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  @override
  Future<String?> getToken() => _messaging.getToken();
}
