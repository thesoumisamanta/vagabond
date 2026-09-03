import 'dart:io';

abstract class StoryEvent {
  const StoryEvent();
}

class GetFollowingStoriesRequested extends StoryEvent {
  const GetFollowingStoriesRequested();
}

class CreateStoryRequested extends StoryEvent {
  final File media;
  final String? caption;

  const CreateStoryRequested({required this.media, this.caption});
}

class GetUserActiveStoriesRequested extends StoryEvent {
  final String userId;

  const GetUserActiveStoriesRequested({required this.userId});
}

class GetArchivedStoriesRequested extends StoryEvent {
  final int page;
  final int limit;

  const GetArchivedStoriesRequested({this.page = 1, this.limit = 20});
}

class ViewStoryRequested extends StoryEvent {
  final String storyId;

  const ViewStoryRequested({required this.storyId});
}

class ReplyToStoryRequested extends StoryEvent {
  final String storyId;
  final String text;

  const ReplyToStoryRequested({required this.storyId, required this.text});
}

class GetStoryViewersRequested extends StoryEvent {
  final String storyId;

  const GetStoryViewersRequested({required this.storyId});
}

class DeleteStoryRequested extends StoryEvent {
  final String storyId;

  const DeleteStoryRequested({required this.storyId});
}

class CreateHighlightRequested extends StoryEvent {
  final String title;
  final List<String> storyIds;
  final File? coverImage;

  const CreateHighlightRequested({required this.title, required this.storyIds, this.coverImage});
}

class GetUserHighlightsRequested extends StoryEvent {
  final String userId;

  const GetUserHighlightsRequested({required this.userId});
}

class UpdateHighlightRequested extends StoryEvent {
  final String highlightId;
  final String title;
  final List<String> storyIds;

  const UpdateHighlightRequested({required this.highlightId, required this.title, required this.storyIds});
}

class DeleteHighlightRequested extends StoryEvent {
  final String highlightId;

  const DeleteHighlightRequested({required this.highlightId});
}
