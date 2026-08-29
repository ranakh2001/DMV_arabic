import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/answer_check_result.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/questions_repository.dart';
import '../datasources/questions_remote_data_source.dart';

class QuestionsRepositoryImpl implements QuestionsRepository {
  const QuestionsRepositoryImpl({required QuestionsRemoteDataSource remote})
    : _remote = remote;

  final QuestionsRemoteDataSource _remote;

  @override
  Future<Result<List<Question>>> getQuestions({required int stateId}) async {
    try {
      final models = await _remote.getQuestions(stateId: stateId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(
        ApiFailure(
          messageAr: e.messageAr,
          messageEn: e.messageEn,
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        ),
      );
    } catch (_) {
      // Anything other than a ServerException here is an unexpected
      // response shape (e.g. an empty-result payload without the usual
      // pagination envelope), not a connectivity problem — don't mislabel
      // it as "no internet".
      return Result.failure(
        const ApiFailure(
          messageAr: 'تعذر جلب الأسئلة. يرجى المحاولة مرة أخرى.',
          messageEn: 'Failed to load questions. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Result<AnswerCheckResult>> checkAnswer({
    required int questionId,
    required String selectedAnswer,
  }) async {
    try {
      final model = await _remote.checkAnswer(
        questionId: questionId,
        selectedAnswer: selectedAnswer,
      );
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(
        ApiFailure(
          messageAr: e.messageAr,
          messageEn: e.messageEn,
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        ),
      );
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
