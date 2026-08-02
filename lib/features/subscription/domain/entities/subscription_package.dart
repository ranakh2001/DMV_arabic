/// A purchasable subscription tier, as configured on the backend.
class SubscriptionPackage {
  const SubscriptionPackage({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.durationDays,
    required this.priceUsd,
    required this.features,
  });

  final int id;
  final String nameEn;
  final String nameAr;
  final int durationDays;
  final double priceUsd;

  /// Feature bullet points, split from the API's single delimited string.
  final List<String> features;

  String name({required bool arabic}) => arabic ? nameAr : nameEn;

  /// Used to rank packages by value (lower is better).
  double get pricePerDay =>
      durationDays == 0 ? priceUsd : priceUsd / durationDays;
}
