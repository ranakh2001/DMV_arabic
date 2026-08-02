import '../../../../core/utils/result.dart';
import '../entities/answer_check_result.dart';
import '../repositories/questions_repository.dart';

class CheckAnswerUsecase {
  const CheckAnswerUsecase(this._repo);
  final QuestionsRepository _repo;

  Future<Result<AnswerCheckResult>> call({
    required int questionId,
    required String selectedAnswer,
  }) =>
      _repo.checkAnswer(questionId: questionId, selectedAnswer: selectedAnswer);
}
