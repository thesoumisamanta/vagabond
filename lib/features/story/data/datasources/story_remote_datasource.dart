import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/features/story/data/models/story_model.dart';

abstract class StoryRemoteDataSource {
  Future<List<UserStoriesModel>> getFollowingStories();
  Future<StoryModel> createStory({required File media, String? caption});
  Future<List<StoryModel>> getUserActiveStories({required String userId});
  Future<ArchivedStoriesResponseModel> getArchivedStories({int page = 1, int limit = 20});
  Future<void> viewStory({required String id});
  Future<void> replyToStory({required String id, required String text});
  Future<List<StoryViewerInfoModel>> getStoryViewers({required String id});
  Future<void> deleteStory({required String id});
  Future<StoryHighlightModel> createHighlight({
    required String title,
    required List<String> storyIds,
    File? coverImage,
  });
  Future<List<StoryHighlightModel>> getUserHighlights({required String userId});
  Future<StoryHighlightModel> updateHighlight({
    required String id,
    required String title,
    required List<String> storyIds,
  });
  Future<void> deleteHighlight({required String id});
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final ApiClient apiClient;

  StoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<UserStoriesModel>> getFollowingStories() async {
    final response = await apiClient.get(ApiEndpoints.followingStories);
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final storiesJson = data['stories'] as List<dynamic>? ?? [];
    return storiesJson.map((s) => UserStoriesModel.fromJson(s as Map<String, dynamic>)).toList();
  }

  @override
  Future<StoryModel> createStory({required File media, String? caption}) async {
    final filename = media.path.split('/').last;
    final formData = FormData.fromMap({'media': await MultipartFile.fromFile(media.path, filename: filename)});
    if (caption != null && caption.isNotEmpty) {
      formData.fields.add(MapEntry('caption', caption));
    }

    final response = await apiClient.post(ApiEndpoints.stories, data: formData);
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final storyJson = data['story'] as Map<String, dynamic>;
    return StoryModel.fromJson(storyJson);
  }

  @override
  Future<List<StoryModel>> getUserActiveStories({required String userId}) async {
    final response = await apiClient.get('${ApiEndpoints.stories}/user/$userId');
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final storiesJson = data['stories'] as List<dynamic>? ?? [];
    return storiesJson.map((s) => StoryModel.fromJson(s as Map<String, dynamic>)).toList();
  }

  @override
  Future<ArchivedStoriesResponseModel> getArchivedStories({int page = 1, int limit = 20}) async {
    final response = await apiClient.get(
      '${ApiEndpoints.stories}/archive',
      queryParameters: {'page': page, 'limit': limit},
    );
    return ArchivedStoriesResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> viewStory({required String id}) async {
    await apiClient.post('${ApiEndpoints.stories}/$id/view');
  }

  @override
  Future<void> replyToStory({required String id, required String text}) async {
    await apiClient.post('${ApiEndpoints.stories}/$id/reply', data: {'text': text});
  }

  @override
  Future<List<StoryViewerInfoModel>> getStoryViewers({required String id}) async {
    final response = await apiClient.get('${ApiEndpoints.stories}/$id/viewers');
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final viewersJson = data['viewers'] as List<dynamic>? ?? [];
    return viewersJson.map((v) => StoryViewerInfoModel.fromJson(v as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> deleteStory({required String id}) async {
    await apiClient.delete('${ApiEndpoints.stories}/$id');
  }

  @override
  Future<StoryHighlightModel> createHighlight({
    required String title,
    required List<String> storyIds,
    File? coverImage,
  }) async {
    final formData = FormData.fromMap({'title': title, 'storyIds': storyIds});
    if (coverImage != null) {
      final filename = coverImage.path.split('/').last;
      formData.files.add(MapEntry('coverImage', await MultipartFile.fromFile(coverImage.path, filename: filename)));
    }

    final response = await apiClient.post('${ApiEndpoints.stories}/highlights', data: formData);
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final highlightJson = data['highlight'] as Map<String, dynamic>;
    return StoryHighlightModel.fromJson(highlightJson);
  }

  @override
  Future<List<StoryHighlightModel>> getUserHighlights({required String userId}) async {
    final response = await apiClient.get('${ApiEndpoints.stories}/highlights/user/$userId');
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final highlightsJson = data['highlights'] as List<dynamic>? ?? [];
    return highlightsJson.map((h) => StoryHighlightModel.fromJson(h as Map<String, dynamic>)).toList();
  }

  @override
  Future<StoryHighlightModel> updateHighlight({
    required String id,
    required String title,
    required List<String> storyIds,
  }) async {
    final response = await apiClient.put(
      '${ApiEndpoints.stories}/highlights/$id',
      data: {'title': title, 'storyIds': storyIds},
    );
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final highlightJson = data['highlight'] as Map<String, dynamic>;
    return StoryHighlightModel.fromJson(highlightJson);
  }

  @override
  Future<void> deleteHighlight({required String id}) async {
    await apiClient.delete('${ApiEndpoints.stories}/highlights/$id');
  }
}
