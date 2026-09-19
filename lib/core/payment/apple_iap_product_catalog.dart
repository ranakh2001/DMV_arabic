/// Maps a backend [SubscriptionPackage]'s duration to the fixed Apple App
/// Store Connect product IDs. The backend package catalogue has no populated
/// field that maps 1:1 to a StoreKit product ID (`apple_product_id` is null),
/// so this matches by exact duration.
class AppleIapProductCatalog {
  AppleIapProductCatalog._();

  static const String monthly = 'com.dmv.us.monthly';
  static const String sixMonths = 'com.dmv.us.sixmonths';

  static const Set<String> productIds = {monthly, sixMonths};

  static const int monthlyDays = 30;
  static const int sixMonthsDays = 180;

  /// Null for any duration that has no App Store product, so such a package
  /// is never sold on iOS (rather than silently charged as another product).
  static String? productIdForDurationDays(int days) => switch (days) {
    monthlyDays => monthly,
    sixMonthsDays => sixMonths,
    _ => null,
  };
}
