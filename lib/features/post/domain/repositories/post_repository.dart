import 'dart:io';
import 'package:vagabond/features/post/domain/entities/post.dart';

abstract class PostRepository {
  Future<String> createPost({required List<File> media, String? caption, String? location, String? tags});

  Future<FeedResponse> getFeedPosts({int page = 1, int limit = 10});
  Future<Post> getPostDetails({required String id});
  Future<LikeDislikeResult> likePost({required String id});
  Future<LikeDislikeResult> dislikePost({required String id});
  Future<SharePostResult> sharePost({required String id});
}
