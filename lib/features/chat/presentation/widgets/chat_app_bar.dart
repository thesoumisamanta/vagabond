import 'package:flutter/material.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Chat? chat;
  final User? currentUser;
  final VoidCallback onBackPressed;

  const ChatAppBar({super.key, required this.chat, required this.currentUser, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    ChatParticipant? otherParticipant;

    if (chat != null) {
      otherParticipant = chat!.participants.cast<ChatParticipant>().firstWhere(
        (p) => p.id != currentUser?.id,
        orElse: () => chat!.participants.first,
      );
    }

    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.02),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed,
      ),
      title: otherParticipant == null
          ? const Text(AppStrings.chatLoading, style: TextStyle(color: Colors.white))
          : Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  backgroundImage: otherParticipant.profilePicture.isNotEmpty
                      ? NetworkImage(otherParticipant.profilePicture)
                      : null,
                  child: otherParticipant.profilePicture.isEmpty
                      ? Text(
                          otherParticipant.fullName.isNotEmpty ? otherParticipant.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherParticipant.fullName.isNotEmpty ? otherParticipant.fullName : otherParticipant.username,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        otherParticipant.isOnline ? AppStrings.chatOnline : AppStrings.chatOffline,
                        style: TextStyle(
                          color: otherParticipant.isOnline ? Colors.green : Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
