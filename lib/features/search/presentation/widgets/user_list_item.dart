import 'package:flutter/material.dart';
import 'package:vagabond/features/search/domain/entities/search_user.dart';

class UserListItem extends StatelessWidget {
  final SearchUser user;
  final VoidCallback onTap;

  const UserListItem({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
            backgroundImage: user.profilePicture.isNotEmpty ? NetworkImage(user.profilePicture) : null,
            child: user.profilePicture.isEmpty
                ? Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                : null,
          ),
          title: Row(
            children: [
              Text(
                user.username,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Color(0xFF6366F1), size: 14),
              ],
            ],
          ),
          subtitle: Text(user.fullName, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          trailing: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.4)),
        ),
      ),
    );
  }
}
