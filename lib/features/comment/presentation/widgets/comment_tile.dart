import 'package:flutter/material.dart';
import 'package:vagabond/features/comment/domain/entities/comment.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final String? currentUserId;
  final bool isReply;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const CommentTile({
    super.key,
    required this.comment,
    this.currentUserId,
    this.isReply = false,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    required this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    final isOwnComment = currentUserId != null && comment.user.id == currentUserId;
    final formattedDate = _formatDate(comment.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          CircleAvatar(
            radius: isReply ? 14 : 18,
            backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
            backgroundImage: comment.user.profilePicture.isNotEmpty ? NetworkImage(comment.user.profilePicture) : null,
            child: comment.user.profilePicture.isEmpty
                ? Text(
                    comment.user.fullName.isNotEmpty ? comment.user.fullName[0].toUpperCase() : 'U',
                    style: TextStyle(fontSize: isReply ? 11 : 14, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username & Date & Actions Menu
                Row(
                  children: [
                    Text(
                      comment.user.username,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isReply ? 12 : 13),
                    ),
                    if (comment.user.isVerified == true) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Color(0xFF6366F1), size: 12),
                    ],
                    const SizedBox(width: 8),
                    Text(formattedDate, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    const Spacer(),
                    if (isOwnComment)
                      PopupMenuButton<String>(
                        color: const Color(0xFF1E293B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
                        ),
                        icon: const Icon(Icons.more_horiz, color: Colors.white54, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit();
                          } else if (value == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16, color: Colors.white70),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Comment Text
                Text(comment.text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3)),
                const SizedBox(height: 6),

                // Action Buttons (Like, Dislike, Reply)
                Row(
                  children: [
                    // Like
                    GestureDetector(
                      onTap: onLike,
                      child: Row(
                        children: [
                          Icon(
                            comment.hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: comment.hasLiked ? const Color(0xFF6366F1) : Colors.white54,
                            size: 14,
                          ),
                          if (comment.likesCount > 0) ...[
                            const SizedBox(width: 4),
                            Text('${comment.likesCount}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Dislike
                    GestureDetector(
                      onTap: onDislike,
                      child: Row(
                        children: [
                          Icon(
                            comment.hasDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                            color: comment.hasDisliked ? const Color(0xFFEF4444) : Colors.white54,
                            size: 14,
                          ),
                          if (comment.dislikesCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${comment.dislikesCount}',
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Reply
                    if (!isReply)
                      GestureDetector(
                        onTap: onReply,
                        child: const Text(
                          'Reply',
                          style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays >= 1) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours >= 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes >= 1) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'just now';
      }
    } catch (e) {
      return '';
    }
  }
}
