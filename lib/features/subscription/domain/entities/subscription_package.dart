/// A purchasable subscription tier, as configured on the backend.
class SubscriptionPackage {
  const SubscriptionPackage({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.durationDays,
    required this.priceUsd,
    required this.features,
    this.storeTitle,
    this.storePrice,
  });

  final int id;
  final String nameEn;
  final String nameAr;
  final int durationDays;
  final double priceUsd;

  /// Feature bullet points, split from the API's single delimited string.
  final List<String> features;

  /// iOS only: the App Store's own localized product title and price string
  /// (from StoreKit `ProductDetails`). When set they replace the backend
  /// name / USD price in the UI, since the store is the source of truth for
  /// what the user is actually charged.
  final String? storeTitle;
  final String? storePrice;

  String name({required bool arabic}) => arabic ? nameAr : nameEn;

  /// Used to rank packages by value (lower is better).
  double get pricePerDay =>
      durationDays == 0 ? priceUsd : priceUsd / durationDays;

  SubscriptionPackage withStoreDetails({
    required String title,
    required String price,
  }) => SubscriptionPackage(
    id: id,
    nameEn: nameEn,
    nameAr: nameAr,
    durationDays: durationDays,
    priceUsd: priceUsd,
    features: features,
    storeTitle: title,
    storePrice: price,
  );
}
