import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vagabond/features/post/domain/entities/post.dart';
import 'package:vagabond/features/post/presentation/widgets/network_video_thumbnail.dart';

class ProfilePostsGrid extends StatelessWidget {
  final List<Post> posts;
  final Function(Post post) onPostTap;

  const ProfilePostsGrid({super.key, required this.posts, required this.onPostTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Posts',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (posts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                children: [
                  Icon(Icons.photo_library_outlined, color: Colors.white.withOpacity(0.3), size: 48),
                  const SizedBox(height: 12),
                  Text('No posts yet', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: posts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final post = posts[index];
              final mediaUrl = post.media.isNotEmpty ? post.media[0].url : '';
              final isVideo = post.media.isNotEmpty && post.media[0].type == 'video';

              return GestureDetector(
                onTap: () => onPostTap(post),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.white.withOpacity(0.05),
                    child: isVideo
                        ? NetworkVideoThumbnail(url: mediaUrl)
                        : (mediaUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: mediaUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.white.withOpacity(0.05),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Icon(Icons.broken_image_outlined, color: Colors.white.withOpacity(0.3)),
                                  ),
                                )
                              : const SizedBox.shrink()),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
