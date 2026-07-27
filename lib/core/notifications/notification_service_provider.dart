import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

/// Provider for the app's [NotificationService].
/// Requires `Firebase.initializeApp()` to have already run (see main.dart).
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => FcmNotificationService(),
);
