import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../data/datasources/simulation_exam_remote_data_source.dart';
import '../../data/repositories/simulation_exam_repository_impl.dart';
import '../../domain/entities/exam_history_entry.dart';
import '../../domain/entities/exam_result_detail.dart';
import '../../domain/entities/exam_summary.dart';
import '../../domain/repositories/simulation_exam_repository.dart';
import '../../domain/usecases/answer_exam_question_usecase.dart';
import '../../domain/usecases/get_exam_history_usecase.dart';
import '../../domain/usecases/get_exam_result_usecase.dart';
import '../../domain/usecases/get_simulation_exams_usecase.dart';
import '../../domain/usecases/start_simulation_exam_usecase.dart';
import '../../domain/usecases/submit_exam_usecase.dart';

final simulationExamRemoteDataSourceProvider =
    Provider<SimulationExamRemoteDataSource>(
      (ref) => SimulationExamRemoteDataSource(ref.watch(dioProvider)),
    );

final simulationExamRepositoryProvider = Provider<SimulationExamRepository>(
  (ref) => SimulationExamRepositoryImpl(
    remote: ref.watch(simulationExamRemoteDataSourceProvider),
  ),
);

final getSimulationExamsUsecaseProvider = Provider(
  (ref) =>
      GetSimulationExamsUsecase(ref.watch(simulationExamRepositoryProvider)),
);

final startSimulationExamUsecaseProvider = Provider(
  (ref) =>
      StartSimulationExamUsecase(ref.watch(simulationExamRepositoryProvider)),
);

final answerExamQuestionUsecaseProvider = Provider(
  (ref) =>
      AnswerExamQuestionUsecase(ref.watch(simulationExamRepositoryProvider)),
);

final submitExamUsecaseProvider = Provider(
  (ref) => SubmitExamUsecase(ref.watch(simulationExamRepositoryProvider)),
);

final getExamResultUsecaseProvider = Provider(
  (ref) => GetExamResultUsecase(ref.watch(simulationExamRepositoryProvider)),
);

final getExamHistoryUsecaseProvider = Provider(
  (ref) => GetExamHistoryUsecase(ref.watch(simulationExamRepositoryProvider)),
);

/// The list of published simulation exams for a given state — shown in
/// [ExamPickerSheet].
final simulationExamsProvider = FutureProvider.family<List<ExamSummary>, int>((
  ref,
  stateId,
) async {
  final result = await ref
      .watch(getSimulationExamsUsecaseProvider)
      .call(stateId: stateId);
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );
});

/// Full score + per-question breakdown for one attempt — used by the
/// post-submit result screen and the history result sheet alike.
final examResultProvider = FutureProvider.family<ExamResultDetail, int>((
  ref,
  attemptId,
) async {
  final result = await ref
      .watch(getExamResultUsecaseProvider)
      .call(attemptId: attemptId);
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );
});

/// The signed-in user's past exam attempts, newest first.
final examHistoryProvider = FutureProvider<List<ExamHistoryEntry>>((ref) async {
  final result = await ref.watch(getExamHistoryUsecaseProvider).call();
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );
});
