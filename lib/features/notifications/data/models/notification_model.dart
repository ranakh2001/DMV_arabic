import '../../domain/entities/app_notification.dart';

/// One row of the paginated `data.data` array on `GET /notifications`.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.titleAr,
    this.titleEn,
    required this.messageAr,
    this.messageEn,
    required this.type,
    required this.readStatus,
    required this.createdAt,
  });

  final int id;
  final String titleAr;
  final String? titleEn;
  final String messageAr;
  final String? messageEn;
  final String type;
  final bool readStatus;
  final DateTime createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as int,
        titleAr: json['title_ar'] as String? ?? '',
        titleEn: json['title_en'] as String?,
        messageAr: json['message_ar'] as String? ?? '',
        messageEn: json['message_en'] as String?,
        type: json['type'] as String? ?? '',
        readStatus: json['read_status'] == true,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  AppNotification toEntity() => AppNotification(
    id: id,
    titleAr: titleAr,
    titleEn: titleEn,
    messageAr: messageAr,
    messageEn: messageEn,
    type: type,
    readStatus: readStatus,
    createdAt: createdAt,
  );
}
