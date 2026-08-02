import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../data/datasources/states_remote_data_source.dart';
import '../../data/repositories/states_repository_impl.dart';
import '../../domain/entities/us_state.dart';
import '../../domain/repositories/states_repository.dart';
import '../../domain/usecases/get_states_usecase.dart';

final statesRemoteDataSourceProvider = Provider<StatesRemoteDataSource>(
  (ref) => StatesRemoteDataSource(ref.watch(dioProvider)),
);

final statesRepositoryProvider = Provider<StatesRepository>(
  (ref) =>
      StatesRepositoryImpl(remote: ref.watch(statesRemoteDataSourceProvider)),
);

final getStatesUsecaseProvider = Provider(
  (ref) => GetStatesUsecase(ref.watch(statesRepositoryProvider)),
);

/// Fetched once and cached for the app session (survives navigating away and
/// back) — both [RegisterScreen] and the onboarding state-selection page
/// read from here instead of each doing their own fetch.
final statesProvider = FutureProvider<List<UsState>>((ref) async {
  ref.keepAlive();
  final result = await ref.watch(getStatesUsecaseProvider).call();
  return result.fold(
    onSuccess: (states) => states,
    onFailure: (failure) => throw failure,
  );
});
