import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/features/post/data/models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<String> createPost({required List<File> media, String? caption, String? location, String? tags});

  Future<FeedResponseModel> getFeedPosts({int page = 1, int limit = 10});
  Future<PostModel> getPostDetails({required String id});
  Future<LikeDislikeResultModel> likePost({required String id});
  Future<LikeDislikeResultModel> dislikePost({required String id});
  Future<SharePostResultModel> sharePost({required String id});
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiClient apiClient;

  PostRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> createPost({required List<File> media, String? caption, String? location, String? tags}) async {
    final formData = FormData();

    for (final file in media) {
      final filename = file.path.split('/').last;
      formData.files.add(MapEntry('media', await MultipartFile.fromFile(file.path, filename: filename)));
    }

    if (caption != null && caption.isNotEmpty) {
      formData.fields.add(MapEntry('caption', caption));
    }
    if (location != null && location.isNotEmpty) {
      formData.fields.add(MapEntry('location', location));
    }
    if (tags != null && tags.isNotEmpty) {
      formData.fields.add(MapEntry('tags', tags));
    }

    final response = await apiClient.post(ApiEndpoints.posts, data: formData);

    final responseData = response.data as Map<String, dynamic>;
    return responseData['message'] as String? ?? 'Post created successfully';
  }

  @override
  Future<FeedResponseModel> getFeedPosts({int page = 1, int limit = 10}) async {
    final response = await apiClient.get('${ApiEndpoints.posts}/feed', queryParameters: {'page': page, 'limit': limit});
    return FeedResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PostModel> getPostDetails({required String id}) async {
    final response = await apiClient.get('${ApiEndpoints.posts}/$id');
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final postJson = data['post'] as Map<String, dynamic>;
    return PostModel.fromJson(postJson);
  }

  @override
  Future<LikeDislikeResultModel> likePost({required String id}) async {
    final response = await apiClient.post('${ApiEndpoints.posts}/$id/like');
    return LikeDislikeResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<LikeDislikeResultModel> dislikePost({required String id}) async {
    final response = await apiClient.post('${ApiEndpoints.posts}/$id/dislike');
    return LikeDislikeResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SharePostResultModel> sharePost({required String id}) async {
    final response = await apiClient.post('${ApiEndpoints.posts}/$id/share');
    return SharePostResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}
