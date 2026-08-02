import '../../domain/entities/subscription_package.dart';

/// Data model for a single object in the `/subscription-packages` list
/// response. Mirrors the API payload field-for-field; [toEntity] projects
/// it down to what the app's presentation layer needs.
class SubscriptionPackageModel {
  const SubscriptionPackageModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.durationDays,
    required this.priceUsd,
    required this.featuresRaw,
    required this.isActive,
  });

  final int id;
  final String nameEn;
  final String nameAr;
  final int durationDays;
  final double priceUsd;
  final String featuresRaw;
  final bool isActive;

  factory SubscriptionPackageModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionPackageModel(
        id: json['id'] as int,
        nameEn: json['name_en'] as String? ?? '',
        nameAr: json['name_ar'] as String? ?? '',
        durationDays: json['duration_days'] as int? ?? 0,
        priceUsd: double.tryParse(json['price_usd']?.toString() ?? '') ?? 0,
        featuresRaw: json['features'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
      );

  /// The `features` field is a single free-text string with items separated
  /// by an Arabic or Latin comma (e.g. "أسئلة غير محدودة، شروحات مفصلة").
  SubscriptionPackage toEntity() => SubscriptionPackage(
    id: id,
    nameEn: nameEn,
    nameAr: nameAr,
    durationDays: durationDays,
    priceUsd: priceUsd,
    features: featuresRaw
        .split(RegExp('[،,]'))
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toList(),
  );
}
