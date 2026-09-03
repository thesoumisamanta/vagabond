import 'package:vagabond/features/comment/domain/entities/comment.dart';
import 'package:vagabond/features/comment/domain/repositories/comment_repository.dart';
import 'package:vagabond/features/comment/data/datasources/comment_remote_datasource.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Comment> createComment({required String postId, required String text, String? parentCommentId}) async {
    try {
      return await remoteDataSource.createComment(postId: postId, text: text, parentCommentId: parentCommentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PostCommentsResponse> getPostComments({required String postId, int page = 1, int limit = 20}) async {
    try {
      return await remoteDataSource.getPostComments(postId: postId, page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CommentRepliesResponse> getCommentReplies({required String commentId, int page = 1, int limit = 10}) async {
    try {
      return await remoteDataSource.getCommentReplies(commentId: commentId, page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Comment> updateComment({required String commentId, required String text}) async {
    try {
      return await remoteDataSource.updateComment(commentId: commentId, text: text);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> deleteComment({required String commentId}) async {
    try {
      return await remoteDataSource.deleteComment(commentId: commentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CommentLikeDislikeResult> likeComment({required String commentId}) async {
    try {
      return await remoteDataSource.likeComment(commentId: commentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CommentLikeDislikeResult> dislikeComment({required String commentId}) async {
    try {
      return await remoteDataSource.dislikeComment(commentId: commentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CommentLikesDislikesUsersResponse> getCommentLikes({required String commentId}) async {
    try {
      return await remoteDataSource.getCommentLikes(commentId: commentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CommentLikesDislikesUsersResponse> getCommentDislikes({required String commentId}) async {
    try {
      return await remoteDataSource.getCommentDislikes(commentId: commentId);
    } catch (e) {
      rethrow;
    }
  }
}
