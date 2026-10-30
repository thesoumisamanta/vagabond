import 'package:flutter/material.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/widgets/whatsapp_theme.dart';

class ReplyPreviewCard extends StatelessWidget {
  final ReplyMessage reply;
  final bool isInsideBubble;
  final bool isMyMessage;
  final VoidCallback? onCancel;

  const ReplyPreviewCard({
    super.key,
    required this.reply,
    this.isInsideBubble = false,
    this.isMyMessage = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final stripColor = isMyMessage ? WhatsAppTheme.replyStripMy : WhatsAppTheme.replyStripOther;
    final displayName = reply.senderFullName != null && reply.senderFullName!.isNotEmpty
        ? reply.senderFullName!
        : (reply.senderUsername.isNotEmpty ? reply.senderUsername : 'User');

    return Container(
      margin: EdgeInsets.only(bottom: isInsideBubble ? 6 : 0),
      decoration: BoxDecoration(
        color: isInsideBubble
            ? WhatsAppTheme.replyQuoteBackground.withOpacity(0.6)
            : WhatsAppTheme.replyQuoteBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: stripColor, width: 4),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: stripColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  reply.messageType != 'text' && reply.text.isEmpty
                      ? '[${reply.messageType}]'
                      : reply.text,
                  style: const TextStyle(
                    color: WhatsAppTheme.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onCancel != null)
            GestureDetector(
              onTap: onCancel,
              child: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.close, color: WhatsAppTheme.iconGrey, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

