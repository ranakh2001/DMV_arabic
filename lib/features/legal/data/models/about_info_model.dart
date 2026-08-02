import '../../domain/entities/about_info.dart';

/// Data model for the `/about` response body.
class AboutInfoModel {
  const AboutInfoModel({
    required this.appName,
    required this.version,
    required this.description,
  });

  final String appName;
  final String version;
  final String description;

  factory AboutInfoModel.fromJson(Map<String, dynamic> json) => AboutInfoModel(
    appName: json['app_name'] as String? ?? '',
    version: json['version'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );

  AboutInfo toEntity() =>
      AboutInfo(appName: appName, version: version, description: description);
}
