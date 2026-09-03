import 'package:flutter/material.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/notification/domain/entities/notification.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({super.key, required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white.withOpacity(0.02) : const Color(0xFF6366F1).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? Colors.white.withOpacity(0.05) : const Color(0xFF6366F1).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Sender Avatar
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: notification.isRead ? Colors.white.withOpacity(0.2) : const Color(0xFF6366F1),
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                backgroundImage: notification.sender.profilePicture.isNotEmpty
                    ? NetworkImage(notification.sender.profilePicture)
                    : null,
                child: notification.sender.profilePicture.isEmpty
                    ? Text(
                        notification.sender.fullName.isNotEmpty ? notification.sender.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Message Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: notification.sender.fullName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: notification.message.replaceFirst(notification.sender.fullName, ''),
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                  ),
                ],
              ),
            ),

            // Post Thumbnail (if exists)
            if (notification.post != null && notification.post!.media.isNotEmpty) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  notification.post!.media.first.url,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.white.withOpacity(0.05),
                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 20),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}${AppStrings.notificationsDaysAgo}';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}${AppStrings.notificationsHoursAgo}';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}${AppStrings.notificationsMinutesAgo}';
    } else {
      return AppStrings.notificationsJustNow;
    }
  }
}
