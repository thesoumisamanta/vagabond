import 'dart:io';
import 'package:vagabond/features/post/domain/entities/post.dart';
import 'package:vagabond/features/post/domain/repositories/post_repository.dart';
import 'package:vagabond/features/post/data/datasources/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> createPost({required List<File> media, String? caption, String? location, String? tags}) async {
    try {
      return await remoteDataSource.createPost(media: media, caption: caption, location: location, tags: tags);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FeedResponse> getFeedPosts({int page = 1, int limit = 10}) async {
    try {
      return await remoteDataSource.getFeedPosts(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Post> getPostDetails({required String id}) async {
    try {
      return await remoteDataSource.getPostDetails(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LikeDislikeResult> likePost({required String id}) async {
    try {
      return await remoteDataSource.likePost(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LikeDislikeResult> dislikePost({required String id}) async {
    try {
      return await remoteDataSource.dislikePost(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SharePostResult> sharePost({required String id}) async {
    try {
      return await remoteDataSource.sharePost(id: id);
    } catch (e) {
      rethrow;
    }
  }
}
