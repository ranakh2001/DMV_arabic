import '../../../../core/utils/result.dart';
import '../entities/exam_answer_result.dart';
import '../repositories/simulation_exam_repository.dart';

class AnswerExamQuestionUsecase {
  const AnswerExamQuestionUsecase(this._repo);
  final SimulationExamRepository _repo;

  Future<Result<ExamAnswerResult>> call({
    required int attemptId,
    required int questionId,
    required String selectedAnswer,
  }) => _repo.answerQuestion(
    attemptId: attemptId,
    questionId: questionId,
    selectedAnswer: selectedAnswer,
  );
}
