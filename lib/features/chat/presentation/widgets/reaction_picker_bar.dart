import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/widgets/whatsapp_theme.dart';

class ReactionPickerBar {
  static void show({
    required BuildContext context,
    required Message message,
    required bool isMe,
    required Function(String emoji) onReact,
    required VoidCallback onReply,
    required VoidCallback onDelete,
  }) {
    HapticFeedback.mediumImpact();
    const emojis = ['❤️', '👍', '😂', '😮', '😢', '🙏'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Reaction Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: WhatsAppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: emojis.map((emoji) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onReact(emoji);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Action Menu
                Container(
                  decoration: BoxDecoration(
                    color: WhatsAppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.reply, color: WhatsAppTheme.primaryGreen),
                        title: const Text('Reply', style: TextStyle(color: WhatsAppTheme.textPrimary)),
                        onTap: () {
                          Navigator.pop(context);
                          onReply();
                        },
                      ),
                      if (message.text.isNotEmpty && !message.isDeleted)
                        ListTile(
                          leading: const Icon(Icons.copy, color: WhatsAppTheme.iconGrey),
                          title: const Text('Copy Text', style: TextStyle(color: WhatsAppTheme.textPrimary)),
                          onTap: () {
                            Navigator.pop(context);
                            Clipboard.setData(ClipboardData(text: message.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      if (isMe && !message.isDeleted)
                        ListTile(
                          leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          title: const Text('Delete for everyone', style: TextStyle(color: Colors.redAccent)),
                          onTap: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

