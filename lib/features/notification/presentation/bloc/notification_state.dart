import 'package:vagabond/features/notification/domain/entities/notification.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoadInProgress extends NotificationState {
  const NotificationLoadInProgress();
}

class NotificationLoadSuccess extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;

  const NotificationLoadSuccess({
    required this.notifications,
    required this.unreadCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasReachedMax,
  });

  NotificationLoadSuccess copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    int? currentPage,
    int? totalPages,
    bool? hasReachedMax,
  }) {
    return NotificationLoadSuccess(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class NotificationLoadFailure extends NotificationState {
  final String error;

  const NotificationLoadFailure({required this.error});
}
