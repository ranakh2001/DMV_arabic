import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/answer_check_model.dart';
import '../models/question_model.dart';

/// Performs the raw HTTP calls for the (Bearer-auth) `/questions` endpoints.
///

/// every active question for the state (mixed general/signs categories),
/// not a 10-question free-trial slice. The client walks through this pool
/// itself, one question at a time, up to the quota reported by
/// `check-answer` (see `FreeTrialController`).
class QuestionsRemoteDataSource {
  const QuestionsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<QuestionModel>> getQuestions({required int stateId}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.questions,
        queryParameters: {'state_id': stateId},
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر جلب الأسئلة.',
        );
      }
      // The API normally paginates (`data: {data: [...], ...}`), but some
      // states with zero questions come back with `data` as a bare empty
      // list instead of the pagination envelope — handle both shapes so
      // an empty result can't crash into a misleading NetworkFailure.
      final rawData = json['data'];
      final list = rawData is Map<String, dynamic>
          ? (rawData['data'] as List<dynamic>? ?? [])
          : (rawData as List<dynamic>? ?? []);
      return list
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map<String, dynamic>
          ? body['message'] as String?
          : null;
      throw ServerException(
        messageAr: message ?? 'تعذر جلب الأسئلة. يرجى المحاولة مرة أخرى.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Grades one answer server-side. The response also carries the
  /// authoritative free-trial usage (`subscription.*`) — this is the client's
  /// only source for how many free questions have been used.
  Future<AnswerCheckModel> checkAnswer({
    required int questionId,
    required String selectedAnswer,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.checkAnswer(questionId),
        data: {'selected_answer': selectedAnswer},
      );
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(
          messageAr: json['message'] as String? ?? 'تعذر التحقق من الإجابة.',
        );
      }
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return AnswerCheckModel.fromJson(data);
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map<String, dynamic>
          ? body['message'] as String?
          : null;
      throw ServerException(
        messageAr: message ?? 'تعذر التحقق من الإجابة. يرجى المحاولة مرة أخرى.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
