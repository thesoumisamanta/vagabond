import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vagabond/features/post/domain/entities/post.dart';
import 'package:vagabond/features/dashboard/presentation/home/widgets/video_player_widget.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class PostDetailsCard extends StatefulWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostDetailsCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onDislike,
    required this.onComment,
    required this.onShare,
  });

  @override
  State<PostDetailsCard> createState() => _PostDetailsCardState();
}

class _PostDetailsCardState extends State<PostDetailsCard> {
  int _currentMediaIndex = 0;

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays >= 1) {
        return '${difference.inDays} ${difference.inDays == 1 ? AppStrings.homeDay : AppStrings.homeDays} ${AppStrings.homeAgo}';
      } else if (difference.inHours >= 1) {
        return '${difference.inHours} ${difference.inHours == 1 ? AppStrings.homeHour : AppStrings.homeHours} ${AppStrings.homeAgo}';
      } else if (difference.inMinutes >= 1) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? AppStrings.homeMinute : AppStrings.homeMinutes} ${AppStrings.homeAgo}';
      } else {
        return AppStrings.homeJustNow;
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final formattedDate = _formatDate(post.createdAt);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withOpacity(0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Profile Picture
                      Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF6366F1), width: 1),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                          backgroundImage: post.user.profilePicture.isNotEmpty
                              ? NetworkImage(post.user.profilePicture)
                              : null,
                          child: post.user.profilePicture.isEmpty
                              ? Text(
                                  post.user.fullName.isNotEmpty ? post.user.fullName[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Username & Location
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  post.user.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (post.user.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: Color(0xFF6366F1), size: 14),
                                ],
                              ],
                            ),
                            if (post.location.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white54, size: 10),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      post.location,
                                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Media Content
                if (post.media.isNotEmpty) ...[
                  AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        PageView.builder(
                          itemCount: post.media.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentMediaIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final mediaItem = post.media[index];
                            if (mediaItem.type == 'video') {
                              return VideoPlayerWidget(url: mediaItem.url);
                            }
                            return CachedNetworkImage(
                              imageUrl: mediaItem.url,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.black12,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.white.withOpacity(0.05),
                                child: const Center(
                                  child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 40),
                                ),
                              ),
                            );
                          },
                        ),
                        // Media Index Indicator
                        if (post.media.length > 1)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_currentMediaIndex + 1}/${post.media.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Like
                      InkWell(
                        onTap: widget.onLike,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${post.likesCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                post.hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                color: post.hasLiked ? const Color(0xFF6366F1) : Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Dislike
                      InkWell(
                        onTap: widget.onDislike,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${post.dislikesCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                post.hasDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                                color: post.hasDisliked ? const Color(0xFFEF4444) : Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Comment
                      InkWell(
                        onTap: widget.onComment,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${post.commentsCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Share
                      InkWell(
                        onTap: widget.onShare,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${post.sharesCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Likes & Caption
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.caption.isNotEmpty) ...[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${post.user.username} ',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              TextSpan(
                                text: post.caption,
                                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (post.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: post.tags.map((tag) {
                            return Text(
                              '#$tag',
                              style: const TextStyle(
                                color: Color(0xFF818CF8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (post.commentsCount > 0) ...[
                        GestureDetector(
                          onTap: widget.onComment,
                          child: Text(
                            '${AppStrings.homeViewAll}${post.commentsCount}${AppStrings.homeComments}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(formattedDate, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
