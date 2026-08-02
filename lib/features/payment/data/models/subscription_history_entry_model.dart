import '../../domain/entities/subscription_history_entry.dart';

class SubscriptionHistoryEntryModel {
  const SubscriptionHistoryEntryModel({
    required this.id,
    required this.packageNameEn,
    required this.packageNameAr,
    required this.status,
    required this.activationDate,
    required this.expiryDate,
    required this.amountUsd,
    required this.paymentStatus,
  });

  final int id;
  final String packageNameEn;
  final String packageNameAr;
  final String status;
  final DateTime activationDate;
  final DateTime expiryDate;
  final double amountUsd;
  final String paymentStatus;

  factory SubscriptionHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    final package = json['package'] as Map<String, dynamic>? ?? const {};
    final payment = json['payment'] as Map<String, dynamic>? ?? const {};
    return SubscriptionHistoryEntryModel(
      id: json['id'] as int,
      packageNameEn: package['name_en'] as String? ?? '',
      packageNameAr: package['name_ar'] as String? ?? '',
      status: json['status'] as String? ?? '',
      activationDate:
          DateTime.tryParse(json['activation_date'] as String? ?? '') ??
          DateTime.now(),
      expiryDate:
          DateTime.tryParse(json['expiry_date'] as String? ?? '') ??
          DateTime.now(),
      amountUsd: double.tryParse(payment['amount_usd']?.toString() ?? '') ?? 0,
      paymentStatus: payment['payment_status'] as String? ?? '',
    );
  }

  SubscriptionHistoryEntry toEntity() => SubscriptionHistoryEntry(
    id: id,
    packageNameEn: packageNameEn,
    packageNameAr: packageNameAr,
    status: status,
    activationDate: activationDate,
    expiryDate: expiryDate,
    amountUsd: amountUsd,
    paymentStatus: paymentStatus,
  );
}
