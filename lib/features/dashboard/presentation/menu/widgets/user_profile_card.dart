import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/core/widgets/glass_card.dart';

class UserProfileCard extends StatelessWidget {
  final User user;

  const UserProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
              backgroundImage: user.profilePictureUrl.isNotEmpty ? NetworkImage(user.profilePictureUrl) : null,
              child: user.profilePictureUrl.isEmpty
                  ? Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text('@${user.username}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white54),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }
}
