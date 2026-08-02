import '../../../subscription/data/models/subscription_package_model.dart';
import '../../domain/entities/user_subscription.dart';

/// Data model for the `data.subscription` object on `/users/profile`.
class UserSubscriptionModel {
  const UserSubscriptionModel({
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
  final SubscriptionPackageModel package;

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      UserSubscriptionModel(
        id: json['id'] as int,
        status: json['status'] as String? ?? '',
        activationDate: DateTime.tryParse(
          json['activation_date'] as String? ?? '',
        ),
        expiryDate: DateTime.tryParse(json['expiry_date'] as String? ?? ''),
        autoRenewal: json['auto_renewal'] as bool? ?? false,
        package: SubscriptionPackageModel.fromJson(
          json['package'] as Map<String, dynamic>,
        ),
      );

  UserSubscription toEntity() => UserSubscription(
    id: id,
    status: status,
    activationDate: activationDate,
    expiryDate: expiryDate,
    autoRenewal: autoRenewal,
    package: package.toEntity(),
  );
}
