import '../../domain/entities/subscription_status.dart';

class SubscriptionStatusModel {
  const SubscriptionStatusModel({required this.hasActiveSubscription});

  final bool hasActiveSubscription;

  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusModel(
      hasActiveSubscription: json['has_active_subscription'] as bool? ?? false,
    );
  }

  SubscriptionStatus toEntity() =>
      SubscriptionStatus(hasActiveSubscription: hasActiveSubscription);
}
