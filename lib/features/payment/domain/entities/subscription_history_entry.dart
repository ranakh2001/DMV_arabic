/// One past or current subscription record, from `GET /subscriptions/history`.
class SubscriptionHistoryEntry {
  const SubscriptionHistoryEntry({
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

  String packageName({required bool arabic}) =>
      arabic ? packageNameAr : packageNameEn;

  bool get isActive => status == 'active';
}
