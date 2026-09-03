import 'package:vagabond/features/comment/domain/entities/comment.dart';

abstract class CommentRepository {
  Future<Comment> createComment({required String postId, required String text, String? parentCommentId});

  Future<PostCommentsResponse> getPostComments({required String postId, int page = 1, int limit = 20});

  Future<CommentRepliesResponse> getCommentReplies({required String commentId, int page = 1, int limit = 10});

  Future<Comment> updateComment({required String commentId, required String text});

  Future<String> deleteComment({required String commentId});

  Future<CommentLikeDislikeResult> likeComment({required String commentId});

  Future<CommentLikeDislikeResult> dislikeComment({required String commentId});

  Future<CommentLikesDislikesUsersResponse> getCommentLikes({required String commentId});

  Future<CommentLikesDislikesUsersResponse> getCommentDislikes({required String commentId});
}
