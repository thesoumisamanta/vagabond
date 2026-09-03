import 'dart:io';
import 'package:vagabond/features/story/domain/entities/story.dart';
import 'package:vagabond/features/story/domain/repositories/story_repository.dart';
import 'package:vagabond/features/story/data/datasources/story_remote_datasource.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource remoteDataSource;

  StoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserStories>> getFollowingStories() async {
    try {
      return await remoteDataSource.getFollowingStories();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Story> createStory({required File media, String? caption}) async {
    try {
      return await remoteDataSource.createStory(media: media, caption: caption);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Story>> getUserActiveStories({required String userId}) async {
    try {
      return await remoteDataSource.getUserActiveStories(userId: userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ArchivedStoriesResponse> getArchivedStories({int page = 1, int limit = 20}) async {
    try {
      return await remoteDataSource.getArchivedStories(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> viewStory({required String id}) async {
    try {
      await remoteDataSource.viewStory(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> replyToStory({required String id, required String text}) async {
    try {
      await remoteDataSource.replyToStory(id: id, text: text);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<StoryViewerInfo>> getStoryViewers({required String id}) async {
    try {
      return await remoteDataSource.getStoryViewers(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteStory({required String id}) async {
    try {
      await remoteDataSource.deleteStory(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StoryHighlight> createHighlight({
    required String title,
    required List<String> storyIds,
    File? coverImage,
  }) async {
    try {
      return await remoteDataSource.createHighlight(title: title, storyIds: storyIds, coverImage: coverImage);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<StoryHighlight>> getUserHighlights({required String userId}) async {
    try {
      return await remoteDataSource.getUserHighlights(userId: userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StoryHighlight> updateHighlight({
    required String id,
    required String title,
    required List<String> storyIds,
  }) async {
    try {
      return await remoteDataSource.updateHighlight(id: id, title: title, storyIds: storyIds);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteHighlight({required String id}) async {
    try {
      await remoteDataSource.deleteHighlight(id: id);
    } catch (e) {
      rethrow;
    }
  }
}
