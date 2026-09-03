import 'package:flutter/material.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/core/widgets/glass_card.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';

class InboxChatTile extends StatelessWidget {
  final Chat chat;
  final User? currentUser;
  final VoidCallback onTap;

  const InboxChatTile({super.key, required this.chat, required this.currentUser, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Find the other participant
    final otherParticipant = chat.participants.cast<ChatParticipant>().firstWhere(
      (p) => p.id != currentUser?.id,
      orElse: () => chat.participants.first,
    );

    final unreadCount = chat.unreadCount[currentUser?.id] ?? 0;
    final hasUnread = unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: onTap,
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  backgroundImage: otherParticipant.profilePicture.isNotEmpty
                      ? NetworkImage(otherParticipant.profilePicture)
                      : null,
                  child: otherParticipant.profilePicture.isEmpty
                      ? Text(
                          otherParticipant.fullName.isNotEmpty ? otherParticipant.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                if (otherParticipant.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0F172A), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    otherParticipant.fullName.isNotEmpty ? otherParticipant.fullName : otherParticipant.username,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (chat.lastMessage != null)
                  Text(
                    _formatTime(chat.lastMessageTime),
                    style: TextStyle(color: hasUnread ? const Color(0xFF6366F1) : Colors.white38, fontSize: 12),
                  ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    chat.lastMessage?.text ??
                        (chat.lastMessage?.media != null
                            ? AppStrings.chatSentMediaMessage
                            : AppStrings.chatNoMessagesYet),
                    style: TextStyle(
                      color: hasUnread ? Colors.white.withOpacity(0.9) : Colors.white54,
                      fontSize: 14,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final now = DateTime.now();
    if (localTime.day == now.day && localTime.month == now.month && localTime.year == now.year) {
      final hour = localTime.hour.toString().padLeft(2, '0');
      final minute = localTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '${localTime.day}/${localTime.month}';
  }
}
