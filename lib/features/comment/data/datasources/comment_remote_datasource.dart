import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/features/comment/data/models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<CommentModel> createComment({required String postId, required String text, String? parentCommentId});

  Future<PostCommentsResponseModel> getPostComments({required String postId, int page = 1, int limit = 20});

  Future<CommentRepliesResponseModel> getCommentReplies({required String commentId, int page = 1, int limit = 10});

  Future<CommentModel> updateComment({required String commentId, required String text});

  Future<String> deleteComment({required String commentId});

  Future<CommentLikeDislikeResultModel> likeComment({required String commentId});

  Future<CommentLikeDislikeResultModel> dislikeComment({required String commentId});

  Future<CommentLikesDislikesUsersResponseModel> getCommentLikes({required String commentId});

  Future<CommentLikesDislikesUsersResponseModel> getCommentDislikes({required String commentId});
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final ApiClient apiClient;

  CommentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CommentModel> createComment({required String postId, required String text, String? parentCommentId}) async {
    final response = await apiClient.post(
      '${ApiEndpoints.comments}/post/$postId',
      data: {'text': text, 'parentCommentId': parentCommentId},
    );
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final commentJson = data['comment'] as Map<String, dynamic>;
    return CommentModel.fromJson(commentJson);
  }

  @override
  Future<PostCommentsResponseModel> getPostComments({required String postId, int page = 1, int limit = 20}) async {
    final response = await apiClient.get(
      '${ApiEndpoints.comments}/post/$postId',
      queryParameters: {'page': page, 'limit': limit},
    );
    return PostCommentsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CommentRepliesResponseModel> getCommentReplies({
    required String commentId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      '${ApiEndpoints.comments}/$commentId/replies',
      queryParameters: {'page': page, 'limit': limit},
    );
    return CommentRepliesResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CommentModel> updateComment({required String commentId, required String text}) async {
    final response = await apiClient.put('${ApiEndpoints.comments}/$commentId', data: {'text': text});
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final commentJson = data['comment'] as Map<String, dynamic>;
    return CommentModel.fromJson(commentJson);
  }

  @override
  Future<String> deleteComment({required String commentId}) async {
    final response = await apiClient.delete('${ApiEndpoints.comments}/$commentId');
    final responseData = response.data as Map<String, dynamic>;
    return responseData['message'] as String? ?? 'Comment deleted successfully';
  }

  @override
  Future<CommentLikeDislikeResultModel> likeComment({required String commentId}) async {
    final response = await apiClient.post('${ApiEndpoints.comments}/$commentId/like');
    return CommentLikeDislikeResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CommentLikeDislikeResultModel> dislikeComment({required String commentId}) async {
    final response = await apiClient.post('${ApiEndpoints.comments}/$commentId/dislike');
    return CommentLikeDislikeResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CommentLikesDislikesUsersResponseModel> getCommentLikes({required String commentId}) async {
    final response = await apiClient.get('${ApiEndpoints.comments}/$commentId/likes');
    return CommentLikesDislikesUsersResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CommentLikesDislikesUsersResponseModel> getCommentDislikes({required String commentId}) async {
    final response = await apiClient.get('${ApiEndpoints.comments}/$commentId/dislikes');
    return CommentLikesDislikesUsersResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
