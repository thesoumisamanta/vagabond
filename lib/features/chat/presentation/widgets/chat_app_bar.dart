import 'package:flutter/material.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/widgets/whatsapp_theme.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Chat? chat;
  final User? currentUser;
  final bool isTyping;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isSearchMode;
  final TextEditingController searchController;
  final VoidCallback onBackPressed;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearChat;

  const ChatAppBar({
    super.key,
    required this.chat,
    required this.currentUser,
    required this.isTyping,
    required this.isOnline,
    this.lastSeen,
    required this.isSearchMode,
    required this.searchController,
    required this.onBackPressed,
    required this.onToggleSearch,
    required this.onSearchChanged,
    required this.onClearChat,
  });

  String _formatSubtitle() {
    if (isTyping) {
      return 'typing...';
    }
    if (isOnline) {
      return 'online';
    }
    if (lastSeen != null) {
      final now = DateTime.now();
      final local = lastSeen!.toLocal();
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');

      if (now.year == local.year && now.month == local.month && now.day == local.day) {
        return 'last seen today at $hour:$minute';
      }

      final yesterday = now.subtract(const Duration(days: 1));
      if (yesterday.year == local.year && yesterday.month == local.month && yesterday.day == local.day) {
        return 'last seen yesterday at $hour:$minute';
      }

      return 'last seen ${local.day}/${local.month} at $hour:$minute';
    }
    return 'offline';
  }

  @override
  Widget build(BuildContext context) {
    if (isSearchMode) {
      return AppBar(
        backgroundColor: WhatsAppTheme.headerBackground,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: WhatsAppTheme.textPrimary),
          onPressed: onToggleSearch,
        ),
        title: TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          autofocus: true,
          style: const TextStyle(color: WhatsAppTheme.textPrimary, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: WhatsAppTheme.textSecondary),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: WhatsAppTheme.iconGrey),
              onPressed: () {
                searchController.clear();
                onSearchChanged('');
              },
            ),
        ],
      );
    }

    ChatParticipant? otherParticipant;
    if (chat != null) {
      otherParticipant = chat!.participants.cast<ChatParticipant>().firstWhere(
        (p) => p.id != currentUser?.id,
        orElse: () => chat!.participants.first,
      );
    }

    return AppBar(
      backgroundColor: WhatsAppTheme.headerBackground,
      elevation: 1,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: WhatsAppTheme.textPrimary),
        onPressed: onBackPressed,
      ),
      title: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: WhatsAppTheme.inputBackground,
                backgroundImage: (otherParticipant != null && otherParticipant.profilePicture.isNotEmpty)
                    ? NetworkImage(otherParticipant.profilePicture)
                    : null,
                child: (otherParticipant == null || otherParticipant.profilePicture.isEmpty)
                    ? Text(
                        otherParticipant?.fullName.isNotEmpty == true
                            ? otherParticipant!.fullName[0].toUpperCase()
                            : (otherParticipant?.username.isNotEmpty == true
                                ? otherParticipant!.username[0].toUpperCase()
                                : 'U'),
                        style: const TextStyle(color: WhatsAppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: WhatsAppTheme.brightGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: WhatsAppTheme.headerBackground, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),

          // Name and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  otherParticipant != null
                      ? (otherParticipant.fullName.isNotEmpty ? otherParticipant.fullName : otherParticipant.username)
                      : 'Chat',
                  style: const TextStyle(
                    color: WhatsAppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatSubtitle(),
                  style: TextStyle(
                    color: isTyping || isOnline ? WhatsAppTheme.primaryGreen : WhatsAppTheme.textSecondary,
                    fontSize: 12,
                    fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: WhatsAppTheme.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined, color: WhatsAppTheme.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.search, color: WhatsAppTheme.textPrimary),
          onPressed: onToggleSearch,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: WhatsAppTheme.textPrimary),
          color: WhatsAppTheme.cardBackground,
          onSelected: (value) {
            if (value == 'clear') {
              onClearChat();
            } else if (value == 'search') {
              onToggleSearch();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'search',
              child: Text('Search', style: TextStyle(color: WhatsAppTheme.textPrimary)),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Text('Clear chat', style: TextStyle(color: WhatsAppTheme.textPrimary)),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
