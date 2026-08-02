import '../../domain/entities/subscription_initiate.dart';

class SubscriptionInitiateModel {
  const SubscriptionInitiateModel({
    required this.paymentId,
    required this.clientSecret,
    required this.customerId,
    required this.ephemeralKey,
    required this.publishableKey,
  });

  final int paymentId;
  final String clientSecret;
  final String customerId;
  final String ephemeralKey;
  final String publishableKey;

  factory SubscriptionInitiateModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionInitiateModel(
      paymentId: json['payment_id'] as int,
      clientSecret: json['client_secret'] as String,
      customerId: json['customer_id'] as String,
      ephemeralKey: json['ephemeral_key'] as String,
      publishableKey: json['publishable_key'] as String,
    );
  }

  SubscriptionInitiate toEntity() => SubscriptionInitiate(
    paymentId: paymentId,
    clientSecret: clientSecret,
    customerId: customerId,
    ephemeralKey: ephemeralKey,
    publishableKey: publishableKey,
  );
}
