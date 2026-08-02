import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/exam_answer_model.dart';
import '../models/exam_attempt_start_model.dart';
import '../models/exam_history_entry_model.dart';
import '../models/exam_result_model.dart';
import '../models/exam_submit_model.dart';
import '../models/exam_summary_model.dart';

/// Performs the raw HTTP calls for the (Bearer-auth) simulation exam flow:
/// list exams for a state, start an attempt, save one answer at a time,
/// submit, then read back results or attempt history.
class SimulationExamRemoteDataSource {
  const SimulationExamRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ExamSummaryModel>> getExams({required int stateId}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.simulationExams,
        queryParameters: {'state_id': stateId},
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر جلب قائمة الاختبارات.',
        );
      }
      final list = json['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ExamSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(
        e,
        'تعذر جلب قائمة الاختبارات. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  Future<ExamAttemptStartModel> startExam({required int examId}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.startSimulationExam(examId),
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر بدء الاختبار.',
        );
      }
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return ExamAttemptStartModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e, 'تعذر بدء الاختبار. يرجى المحاولة مرة أخرى.');
    }
  }

  Future<ExamAnswerModel> answerQuestion({
    required int attemptId,
    required int questionId,
    required String selectedAnswer,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.examAttemptAnswers(attemptId),
        data: {'question_id': '$questionId', 'selected_answer': selectedAnswer},
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر حفظ الإجابة.',
        );
      }
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return ExamAnswerModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e, 'تعذر حفظ الإجابة. يرجى المحاولة مرة أخرى.');
    }
  }

  Future<ExamSubmitModel> submitExam({required int attemptId}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.submitExamAttempt(attemptId),
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر تسليم الاختبار.',
        );
      }
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return ExamSubmitModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e, 'تعذر تسليم الاختبار. يرجى المحاولة مرة أخرى.');
    }
  }

  Future<ExamResultModel> getExamResults({required int attemptId}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.examAttemptResults(attemptId),
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر جلب نتيجة الاختبار.',
        );
      }
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return ExamResultModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e, 'تعذر جلب نتيجة الاختبار. يرجى المحاولة مرة أخرى.');
    }
  }

  Future<List<ExamHistoryEntryModel>> getExamHistory() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.examAttemptHistory,
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر جلب سجل المحاولات.',
        );
      }
      final page = json['data'] as Map<String, dynamic>? ?? {};
      final list = page['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ExamHistoryEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e, 'تعذر جلب سجل المحاولات. يرجى المحاولة مرة أخرى.');
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
