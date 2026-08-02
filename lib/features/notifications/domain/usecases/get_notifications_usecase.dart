import '../../../../core/utils/result.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUsecase {
  const GetNotificationsUsecase(this._repo);
  final NotificationsRepository _repo;

  Future<Result<List<AppNotification>>> call() => _repo.getNotifications();
}
