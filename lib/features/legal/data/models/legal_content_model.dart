import '../../domain/entities/legal_content.dart';

/// Data model for the `{ title, content }` shape returned by both
/// `/privacy-policy` and `/terms`.
class LegalContentModel {
  const LegalContentModel({required this.title, required this.content});

  final String title;
  final String content;

  factory LegalContentModel.fromJson(Map<String, dynamic> json) =>
      LegalContentModel(
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
      );

  LegalContent toEntity() => LegalContent(title: title, content: content);
}
