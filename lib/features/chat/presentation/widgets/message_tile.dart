import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/widgets/message_status_tick.dart';
import 'package:vagabond/features/chat/presentation/widgets/reply_preview_card.dart';
import 'package:vagabond/features/chat/presentation/widgets/whatsapp_theme.dart';
import 'package:vagabond/features/dashboard/presentation/home/widgets/video_player_widget.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final User? currentUser;
  final VoidCallback onLongPress;
  final VoidCallback onReply;

  const MessageTile({
    super.key,
    required this.message,
    required this.currentUser,
    required this.onLongPress,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender.id == currentUser?.id;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dismissible(
      key: Key('reply_${message.id}'),
      direction: isMe ? DismissDirection.endToStart : DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        onReply();
        return false; // Don't actually dismiss the tile
      },
      background: Container(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.reply, color: WhatsAppTheme.primaryGreen, size: 24),
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            margin: const EdgeInsets.only(bottom: 4, top: 4),
            constraints: BoxConstraints(maxWidth: screenWidth * 0.78),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Message Bubble Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isMe ? WhatsAppTheme.myMessageBubble : WhatsAppTheme.otherMessageBubble,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isMe ? 12 : 2),
                      bottomRight: Radius.circular(isMe ? 2 : 12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Reply Preview if replied
                      if (message.replyTo != null)
                        ReplyPreviewCard(
                          reply: message.replyTo!,
                          isInsideBubble: true,
                          isMyMessage: isMe,
                        ),

                      // Media Content (Image / Video)
                      if (message.media != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: message.media!.type == 'video'
                              ? SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: VideoPlayerWidget(url: message.media!.url),
                                )
                              : CachedNetworkImage(
                                  imageUrl: message.media!.url,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(WhatsAppTheme.primaryGreen),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => const SizedBox(
                                    height: 100,
                                    child: Center(child: Icon(Icons.broken_image, color: WhatsAppTheme.iconGrey)),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Message Text & Metadata Row
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        runSpacing: 2,
                        spacing: 8,
                        children: [
                          // Message Text
                          if (message.text.isNotEmpty)
                            Text(
                              message.text,
                              style: TextStyle(
                                color: message.isDeleted ? WhatsAppTheme.textSecondary : WhatsAppTheme.textPrimary,
                                fontSize: 15,
                                fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
                                height: 1.25,
                              ),
                            ),

                          // Time and Tick
                          Padding(
                            padding: const EdgeInsets.only(top: 2, left: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(message.createdAt),
                                  style: const TextStyle(
                                    color: WhatsAppTheme.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  MessageStatusTick(status: message.status),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Reactions Badge
                if (message.reactions.isNotEmpty)
                  Positioned(
                    bottom: -10,
                    right: isMe ? 4 : null,
                    left: isMe ? null : 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: WhatsAppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _condenseReactions(message.reactions),
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (message.reactions.length > 1) ...[
                            const SizedBox(width: 2),
                            Text(
                              '${message.reactions.length}',
                              style: const TextStyle(color: WhatsAppTheme.textSecondary, fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _condenseReactions(List<MessageReaction> reactions) {
    final seen = <String>{};
    final buffer = StringBuffer();
    for (final r in reactions) {
      if (!seen.contains(r.emoji)) {
        seen.add(r.emoji);
        buffer.write(r.emoji);
      }
      if (seen.length >= 3) break;
    }
    return buffer.toString();
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
