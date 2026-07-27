/// A US state as configured on the backend (DMV question bank sizing, etc).
class UsState {
  const UsState({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.abbreviation,
    required this.dmvQuestionCount,
    required this.dmvPassingScore,
    this.iconUrl,
  });

  final int id;
  final String nameEn;
  final String nameAr;
  final String abbreviation;
  final int dmvQuestionCount;
  final int dmvPassingScore;
  final String? iconUrl;

  String name({required bool arabic}) => arabic ? nameAr : nameEn;
}
