import 'package:vagabond/features/notification/domain/entities/notification.dart';
import 'package:vagabond/features/notification/domain/repositories/notification_repository.dart';
import 'package:vagabond/features/notification/data/datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NotificationListResponse> getNotifications({int page = 1, int limit = 20}) {
    return remoteDataSource.getNotifications(page: page, limit: limit);
  }

  @override
  Future<void> markAsRead({required String id}) {
    return remoteDataSource.markAsRead(id: id);
  }

  @override
  Future<void> markAllAsRead() {
    return remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification({required String id}) {
    return remoteDataSource.deleteNotification(id: id);
  }
}
