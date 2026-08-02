import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remote,
  }) : _remote = remote;

  final NotificationsRemoteDataSource _remote;

  @override
  Future<Result<List<AppNotification>>> getNotifications() async {
    try {
      final models = await _remote.getNotifications();
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
      return Result.failure(const NetworkFailure());
    }
  }
}
