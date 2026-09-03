import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_event.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_state.dart';

class NotificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                AppStrings.notificationsTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              final hasUnread = state is NotificationLoadSuccess && state.unreadCount > 0;
              return TextButton.icon(
                onPressed: hasUnread
                    ? () {
                        context.read<NotificationBloc>().add(const MarkAllNotificationsAsReadRequested());
                      }
                    : null,
                icon: Icon(
                  Icons.done_all,
                  color: hasUnread ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.3),
                  size: 18,
                ),
                label: Text(
                  AppStrings.notificationsReadAll,
                  style: TextStyle(
                    color: hasUnread ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}
