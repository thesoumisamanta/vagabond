import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/dashboard/presentation/home/widgets/video_player_widget.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final User? currentUser;
  final VoidCallback onLongPress;

  const MessageTile({super.key, required this.message, required this.currentUser, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender.id == currentUser?.id;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Message Bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF6366F1).withOpacity(0.85) : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 16),
                  ),
                  border: Border.all(
                    color: isMe ? const Color(0xFF6366F1).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.media != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: message.media!.type == 'video'
                            ? SizedBox(height: 200, child: VideoPlayerWidget(url: message.media!.url))
                            : CachedNetworkImage(
                                imageUrl: message.media!.url,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      message.text,
                      style: TextStyle(
                        color: message.isDeleted ? Colors.white38 : Colors.white,
                        fontSize: 15,
                        fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Reactions & Time
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.reactions.isNotEmpty) ...[
                    Wrap(
                      spacing: 2,
                      children: message.reactions.map((r) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(r.emoji, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(_formatTime(message.createdAt), style: const TextStyle(color: Colors.white30, fontSize: 10)),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.done_all, size: 14, color: message.isRead ? const Color(0xFF6366F1) : Colors.white30),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
