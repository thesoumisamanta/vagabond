import 'package:vagabond/features/notification/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<NotificationListResponse> getNotifications({int page = 1, int limit = 20});
  Future<void> markAsRead({required String id});
  Future<void> markAllAsRead();
  Future<void> deleteNotification({required String id});
}
