import 'package:flutter/material.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/widgets/message_status_tick.dart';
import 'package:vagabond/features/chat/presentation/widgets/whatsapp_theme.dart';

class InboxChatTile extends StatelessWidget {
  final Chat chat;
  final User? currentUser;
  final bool isTyping;
  final VoidCallback onTap;

  const InboxChatTile({
    super.key,
    required this.chat,
    required this.currentUser,
    this.isTyping = false,
    required this.onTap,
  });

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final now = DateTime.now();

    if (localTime.year == now.year && localTime.month == now.month && localTime.day == now.day) {
      final hour = localTime.hour.toString().padLeft(2, '0');
      final minute = localTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == localTime.year && yesterday.month == localTime.month && yesterday.day == localTime.day) {
      return 'Yesterday';
    }

    return '${localTime.day}/${localTime.month}/${localTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final otherParticipant = chat.participants.cast<ChatParticipant?>().firstWhere(
          (p) => p?.id != currentUser?.id,
          orElse: () => chat.participants.isNotEmpty ? chat.participants.first : null,
        );

    final unreadCount = chat.unreadCount[currentUser?.id] ?? 0;
    final hasUnread = unreadCount > 0;
    final isLastMessageMine = chat.lastMessage?.sender.id == currentUser?.id;

    final displayName = otherParticipant?.fullName.isNotEmpty == true
        ? otherParticipant!.fullName
        : (otherParticipant?.username.isNotEmpty == true ? otherParticipant!.username : 'Unknown');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.04),
              width: 0.8,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar with Online Badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: WhatsAppTheme.inputBackground,
                  backgroundImage: (otherParticipant != null && otherParticipant.profilePicture.isNotEmpty)
                      ? NetworkImage(otherParticipant.profilePicture)
                      : null,
                  child: (otherParticipant == null || otherParticipant.profilePicture.isEmpty)
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: WhatsAppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                if (otherParticipant?.isOnline == true)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: WhatsAppTheme.brightGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: WhatsAppTheme.darkBackground, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Middle Content: Name & Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            color: WhatsAppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: TextStyle(
                          color: hasUnread ? WhatsAppTheme.brightGreen : WhatsAppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Subtitle row (Last Message / Typing / Unread Badge)
                  Row(
                    children: [
                      Expanded(
                        child: isTyping
                            ? const Text(
                                'typing...',
                                style: TextStyle(
                                  color: WhatsAppTheme.brightGreen,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : Row(
                                children: [
                                  if (isLastMessageMine && chat.lastMessage != null) ...[
                                    MessageStatusTick(
                                      status: chat.lastMessage!.status,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  if (chat.lastMessage?.media != null) ...[
                                    Icon(
                                      chat.lastMessage!.media!.type == 'video'
                                          ? Icons.videocam
                                          : Icons.camera_alt,
                                      size: 14,
                                      color: WhatsAppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Expanded(
                                    child: Text(
                                      chat.lastMessage?.text.isNotEmpty == true
                                          ? chat.lastMessage!.text
                                          : (chat.lastMessage?.media != null
                                              ? (chat.lastMessage!.media!.type == 'video' ? 'Video' : 'Photo')
                                              : 'No messages yet'),
                                      style: TextStyle(
                                        color: hasUnread ? WhatsAppTheme.textPrimary : WhatsAppTheme.textSecondary,
                                        fontSize: 14,
                                        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: const BoxDecoration(
                            color: WhatsAppTheme.unreadBadgeGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
