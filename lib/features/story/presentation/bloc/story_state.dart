import 'package:vagabond/features/story/domain/entities/story.dart';

abstract class StoryState {
  const StoryState();
}

class StoryInitial extends StoryState {
  const StoryInitial();
}

class StoryLoading extends StoryState {
  const StoryLoading();
}

class StoryLoaded extends StoryState {
  final List<UserStories> userStories;
  const StoryLoaded({required this.userStories});
}

class StoryFailure extends StoryState {
  final String error;
  const StoryFailure({required this.error});
}

class StoryActionSuccess extends StoryState {
  final String message;
  const StoryActionSuccess({required this.message});
}

class UserActiveStoriesLoaded extends StoryState {
  final List<Story> stories;
  const UserActiveStoriesLoaded({required this.stories});
}

class ArchivedStoriesLoaded extends StoryState {
  final ArchivedStoriesResponse response;
  const ArchivedStoriesLoaded({required this.response});
}

class StoryViewersLoaded extends StoryState {
  final List<StoryViewerInfo> viewers;
  const StoryViewersLoaded({required this.viewers});
}

class StoryHighlightsLoaded extends StoryState {
  final List<StoryHighlight> highlights;
  const StoryHighlightsLoaded({required this.highlights});
}

class StoryHighlightActionSuccess extends StoryState {
  final StoryHighlight highlight;
  final String message;
  const StoryHighlightActionSuccess({required this.highlight, required this.message});
}
