import '../../../subscription/domain/entities/subscription_package.dart';

/// The user's current subscription, embedded in `/users/profile`.
class UserSubscription {
  const UserSubscription({
    required this.id,
    required this.status,
    this.activationDate,
    this.expiryDate,
    required this.autoRenewal,
    required this.package,
  });

  final int id;
  final String status;
  final DateTime? activationDate;
  final DateTime? expiryDate;
  final bool autoRenewal;
  final SubscriptionPackage package;

  bool get isActive => status == 'active';
}
