import 'dart:io';
import 'package:vagabond/features/story/domain/entities/story.dart';

abstract class StoryRepository {
  Future<List<UserStories>> getFollowingStories();
  Future<Story> createStory({required File media, String? caption});
  Future<List<Story>> getUserActiveStories({required String userId});
  Future<ArchivedStoriesResponse> getArchivedStories({int page = 1, int limit = 20});
  Future<void> viewStory({required String id});
  Future<void> replyToStory({required String id, required String text});
  Future<List<StoryViewerInfo>> getStoryViewers({required String id});
  Future<void> deleteStory({required String id});
  Future<StoryHighlight> createHighlight({required String title, required List<String> storyIds, File? coverImage});
  Future<List<StoryHighlight>> getUserHighlights({required String userId});
  Future<StoryHighlight> updateHighlight({required String id, required String title, required List<String> storyIds});
  Future<void> deleteHighlight({required String id});
}
