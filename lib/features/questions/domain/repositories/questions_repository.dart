import '../../../../core/utils/result.dart';
import '../entities/answer_check_result.dart';
import '../entities/question.dart';

abstract interface class QuestionsRepository {
  Future<Result<List<Question>>> getQuestions({required int stateId});

  Future<Result<AnswerCheckResult>> checkAnswer({
    required int questionId,
    required String selectedAnswer,
  });
}
