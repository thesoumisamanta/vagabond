import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/features/notification/domain/entities/notification.dart';
import 'package:vagabond/features/notification/domain/repositories/notification_repository.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_event.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository}) : super(const NotificationInitial()) {
    on<GetNotificationsRequested>(_onGetNotificationsRequested);
    on<MarkNotificationAsReadRequested>(_onMarkNotificationAsReadRequested);
    on<MarkAllNotificationsAsReadRequested>(_onMarkAllNotificationsAsReadRequested);
    on<DeleteNotificationRequested>(_onDeleteNotificationRequested);
  }

  Future<void> _onGetNotificationsRequested(GetNotificationsRequested event, Emitter<NotificationState> emit) async {
    final currentState = state;
    if (event.page == 1) {
      emit(const NotificationLoadInProgress());
    }

    try {
      final response = await notificationRepository.getNotifications(page: event.page, limit: event.limit);

      if (event.page == 1) {
        emit(
          NotificationLoadSuccess(
            notifications: response.notifications,
            unreadCount: response.unreadCount,
            currentPage: response.currentPage,
            totalPages: response.totalPages,
            hasReachedMax: response.currentPage >= response.totalPages,
          ),
        );
      } else {
        if (currentState is NotificationLoadSuccess) {
          emit(
            NotificationLoadSuccess(
              notifications: [...currentState.notifications, ...response.notifications],
              unreadCount: response.unreadCount, // Use the latest unreadCount from server
              currentPage: response.currentPage,
              totalPages: response.totalPages,
              hasReachedMax: response.currentPage >= response.totalPages,
            ),
          );
        }
      }
    } catch (e) {
      emit(NotificationLoadFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onMarkNotificationAsReadRequested(
    MarkNotificationAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoadSuccess) {
      // Optimistic update
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == event.id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      final wasUnread = currentState.notifications.any((n) => n.id == event.id && !n.isRead);
      final updatedUnreadCount = wasUnread
          ? (currentState.unreadCount - 1).clamp(0, double.infinity).toInt()
          : currentState.unreadCount;

      emit(currentState.copyWith(notifications: updatedNotifications, unreadCount: updatedUnreadCount));

      try {
        await notificationRepository.markAsRead(id: event.id);
      } catch (e) {
        // Rollback on failure if needed, but usually we can just ignore or reload
      }
    }
  }

  Future<void> _onMarkAllNotificationsAsReadRequested(
    MarkAllNotificationsAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoadSuccess) {
      // Optimistic update
      final updatedNotifications = currentState.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      emit(currentState.copyWith(notifications: updatedNotifications, unreadCount: 0));

      try {
        await notificationRepository.markAllAsRead();
      } catch (e) {
        // Rollback on failure if needed
      }
    }
  }

  Future<void> _onDeleteNotificationRequested(
    DeleteNotificationRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoadSuccess) {
      final target = currentState.notifications.firstWhere((n) => n.id == event.id);
      final updatedNotifications = currentState.notifications.where((n) => n.id != event.id).toList();
      final updatedUnreadCount = !target.isRead
          ? (currentState.unreadCount - 1).clamp(0, double.infinity).toInt()
          : currentState.unreadCount;

      emit(currentState.copyWith(notifications: updatedNotifications, unreadCount: updatedUnreadCount));

      try {
        await notificationRepository.deleteNotification(id: event.id);
      } catch (e) {
        // Rollback on failure if needed
      }
    }
  }
}

// Add copyWith to NotificationEntity for easy updates
extension NotificationEntityExtension on NotificationEntity {
  NotificationEntity copyWith({
    String? id,
    String? recipient,
    dynamic sender,
    String? type,
    dynamic post,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      recipient: recipient ?? this.recipient,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      post: post ?? this.post,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
