import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/features/notification/domain/entities/notification.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_event.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_state.dart';
import 'package:vagabond/features/notification/presentation/widgets/notification_empty_state.dart';
import 'package:vagabond/features/notification/presentation/widgets/notification_tile.dart';
import 'package:vagabond/features/notification/presentation/widgets/notification_app_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch notifications on load
    context.read<NotificationBloc>().add(const GetNotificationsRequested(page: 1));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<NotificationBloc>().state;
      if (state is NotificationLoadSuccess && !state.hasReachedMax) {
        context.read<NotificationBloc>().add(GetNotificationsRequested(page: state.currentPage + 1));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _handleNotificationTap(NotificationEntity notification) {
    // Mark as read
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(MarkNotificationAsReadRequested(id: notification.id));
    }

    // Navigate based on type/post
    if (notification.post != null) {
      context.push('/post/${notification.post!.id}');
    } else if (notification.sender.id.isNotEmpty) {
      context.push('/profile/${notification.sender.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF1E1B4B), // Indigo 950
              Color(0xFF0F172A), // Slate 900
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              const NotificationAppBar(),

              // Notifications List
              Expanded(
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoadInProgress) {
                      return const Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
                      );
                    } else if (state is NotificationLoadFailure) {
                      return Center(
                        child: Text(state.error, style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
                      );
                    } else if (state is NotificationLoadSuccess) {
                      final notifications = state.notifications;
                      if (notifications.isEmpty) {
                        return const NotificationEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<NotificationBloc>().add(const GetNotificationsRequested(page: 1));
                        },
                        color: const Color(0xFF6366F1),
                        backgroundColor: const Color(0xFF1E1B4B),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: notifications.length + (state.hasReachedMax ? 0 : 1),
                          itemBuilder: (context, index) {
                            if (index >= notifications.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                  ),
                                ),
                              );
                            }

                            final notification = notifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Dismissible(
                                key: Key(notification.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  context.read<NotificationBloc>().add(
                                    DeleteNotificationRequested(id: notification.id),
                                  );
                                },
                                child: NotificationTile(
                                  notification: notification,
                                  onTap: () => _handleNotificationTap(notification),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
