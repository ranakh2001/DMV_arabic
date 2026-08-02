import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../data/datasources/notifications_remote_data_source.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/usecases/get_notifications_usecase.dart';

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>(
      (ref) => NotificationsRemoteDataSource(ref.watch(dioProvider)),
    );

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepositoryImpl(
    remote: ref.watch(notificationsRemoteDataSourceProvider),
  ),
);

final getNotificationsUsecaseProvider = Provider(
  (ref) => GetNotificationsUsecase(ref.watch(notificationsRepositoryProvider)),
);

/// Backed by `GET /notifications`. Watched by [NotificationsListScreen].
final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final result = await ref.watch(getNotificationsUsecaseProvider).call();
  return result.fold(
    onSuccess: (notifications) => notifications,
    onFailure: (failure) => throw failure,
  );
});
