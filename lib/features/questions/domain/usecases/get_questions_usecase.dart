import '../../../../core/utils/result.dart';
import '../entities/question.dart';
import '../repositories/questions_repository.dart';

class GetQuestionsUsecase {
  const GetQuestionsUsecase(this._repo);
  final QuestionsRepository _repo;

  Future<Result<List<Question>>> call({required int stateId}) =>
      _repo.getQuestions(stateId: stateId);
}
