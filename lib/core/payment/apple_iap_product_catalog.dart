/// Maps a backend [SubscriptionPackage]'s duration to the fixed Apple App
/// Store Connect product IDs. The backend package catalogue has no field
/// that maps 1:1 to a StoreKit product ID, so this matches by duration —
/// the only two packages in play are ~30 days and ~180 days.
class AppleIapProductCatalog {
  AppleIapProductCatalog._();

  static const String monthly = 'com.dmv.us.monthly';
  static const String sixMonths = 'com.dmv.us.sixmonths';

  static const Set<String> productIds = {monthly, sixMonths};

  static String productIdForDurationDays(int days) =>
      days <= 45 ? monthly : sixMonths;
}
