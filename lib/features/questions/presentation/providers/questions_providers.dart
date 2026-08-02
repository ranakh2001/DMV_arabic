import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../data/datasources/questions_remote_data_source.dart';
import '../../data/repositories/questions_repository_impl.dart';
import '../../domain/repositories/questions_repository.dart';
import '../../domain/usecases/check_answer_usecase.dart';
import '../../domain/usecases/get_questions_usecase.dart';

final questionsRemoteDataSourceProvider = Provider<QuestionsRemoteDataSource>(
  (ref) => QuestionsRemoteDataSource(ref.watch(dioProvider)),
);

final questionsRepositoryProvider = Provider<QuestionsRepository>(
  (ref) => QuestionsRepositoryImpl(
    remote: ref.watch(questionsRemoteDataSourceProvider),
  ),
);

final getQuestionsUsecaseProvider = Provider(
  (ref) => GetQuestionsUsecase(ref.watch(questionsRepositoryProvider)),
);

final checkAnswerUsecaseProvider = Provider(
  (ref) => CheckAnswerUsecase(ref.watch(questionsRepositoryProvider)),
);
