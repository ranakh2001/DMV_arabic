import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/about_info_model.dart';
import '../models/legal_content_model.dart';

/// Performs the raw HTTP calls for the legal/support endpoints: the three
/// public (no-auth) content GETs and the authenticated Contact Us POST (the
/// bearer token is attached automatically by [AuthInterceptor]).
class LegalRemoteDataSource {
  const LegalRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LegalContentModel> getPrivacyPolicy() => _getContent(
    ApiConstants.privacyPolicy,
    fallback: 'تعذر جلب سياسة الخصوصية. يرجى المحاولة مرة أخرى.',
  );

  Future<LegalContentModel> getTerms() => _getContent(
    ApiConstants.terms,
    fallback: 'تعذر جلب شروط الاستخدام. يرجى المحاولة مرة أخرى.',
  );

  Future<LegalContentModel> _getContent(
    String path, {
    required String fallback,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? fallback,
        );
      }
      return LegalContentModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map<String, dynamic>
          ? body['message'] as String?
          : null;
      throw ServerException(
        messageAr: message ?? fallback,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<AboutInfoModel> getAboutUs() async {
    const fallback = 'تعذر جلب معلومات التطبيق. يرجى المحاولة مرة أخرى.';
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.aboutUs,
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? fallback,
        );
      }
      return AboutInfoModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map<String, dynamic>
          ? body['message'] as String?
          : null;
      throw ServerException(
        messageAr: message ?? fallback,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Sends a support message. Returns the server's confirmation message.
  Future<String> sendContactMessage(String message) async {
    const fallback = 'تعذر إرسال رسالتك. يرجى المحاولة مرة أخرى.';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.contactUs,
        data: {'message': message},
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? fallback,
        );
      }
      return json['message'] as String? ?? '';
    } on DioException catch (e) {
      final body = e.response?.data;
      final serverMessage = body is Map<String, dynamic>
          ? body['message'] as String?
          : null;
      throw ServerException(
        messageAr: serverMessage ?? fallback,
        statusCode: e.response?.statusCode,
      );
    }
  }
}
