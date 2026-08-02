/// A single notification item from `GET /notifications`.
class AppNotification {
  const AppNotification({
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

  String title({required bool arabic}) =>
      arabic ? titleAr : (titleEn ?? titleAr);
  String message({required bool arabic}) =>
      arabic ? messageAr : (messageEn ?? messageAr);
}
