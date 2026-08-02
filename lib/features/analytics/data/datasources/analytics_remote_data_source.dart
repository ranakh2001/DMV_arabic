import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/analytics_progress_entry_model.dart';
import '../models/analytics_summary_model.dart';
import '../models/category_analytics_model.dart';

/// Performs the raw HTTP calls for the (Bearer-auth) analytics endpoints —
/// summary totals, per-attempt score progress, and per-category breakdown.
class AnalyticsRemoteDataSource {
  const AnalyticsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AnalyticsSummaryModel> getSummary() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.analyticsSummary,
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر جلب ملخص الإحصائيات.',
        );
      }
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return AnalyticsSummaryModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(
        e,
        'تعذر جلب ملخص الإحصائيات. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  Future<List<AnalyticsProgressEntryModel>> getProgress() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.analyticsProgress,
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر جلب تطور الأداء.',
        );
      }
      final list = json['data'] as List<dynamic>? ?? [];
      return list
          .map(
            (e) =>
                AnalyticsProgressEntryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e, 'تعذر جلب تطور الأداء. يرجى المحاولة مرة أخرى.');
    }
  }

  Future<List<CategoryAnalyticsModel>> getByCategory() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.analyticsByCategory,
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr:
              json['message'] as String? ?? 'تعذر جلب الإحصائيات حسب الفئة.',
        );
      }
      final list = json['data'] as List<dynamic>? ?? [];
      return list
          .map(
            (e) => CategoryAnalyticsModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(
        e,
        'تعذر جلب الإحصائيات حسب الفئة. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  ServerException _mapDioError(DioException e, String fallback) {
    final body = e.response?.data;
    final message = body is Map<String, dynamic>
        ? body['message'] as String?
        : null;
    return ServerException(
      messageAr: message ?? fallback,
      statusCode: e.response?.statusCode,
    );
  }
}
