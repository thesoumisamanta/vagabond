abstract class NotificationEvent {
  const NotificationEvent();
}

class GetNotificationsRequested extends NotificationEvent {
  final int page;
  final int limit;

  const GetNotificationsRequested({this.page = 1, this.limit = 20});
}

class MarkNotificationAsReadRequested extends NotificationEvent {
  final String id;

  const MarkNotificationAsReadRequested({required this.id});
}

class MarkAllNotificationsAsReadRequested extends NotificationEvent {
  const MarkAllNotificationsAsReadRequested();
}

class DeleteNotificationRequested extends NotificationEvent {
  final String id;

  const DeleteNotificationRequested({required this.id});
}
