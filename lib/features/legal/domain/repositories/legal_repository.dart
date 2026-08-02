import '../../../../core/utils/result.dart';
import '../entities/about_info.dart';
import '../entities/legal_content.dart';

abstract interface class LegalRepository {
  Future<Result<LegalContent>> getPrivacyPolicy();
  Future<Result<LegalContent>> getTerms();
  Future<Result<AboutInfo>> getAboutUs();
  Future<Result<String>> sendContactMessage(String message);
}
