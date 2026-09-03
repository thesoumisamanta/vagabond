import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/features/story/domain/repositories/story_repository.dart';
import 'package:vagabond/features/story/presentation/bloc/story_event.dart';
import 'package:vagabond/features/story/presentation/bloc/story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final StoryRepository storyRepository;

  StoryBloc({required this.storyRepository}) : super(const StoryInitial()) {
    on<GetFollowingStoriesRequested>(_onGetFollowingStoriesRequested);
    on<CreateStoryRequested>(_onCreateStoryRequested);
    on<GetUserActiveStoriesRequested>(_onGetUserActiveStoriesRequested);
    on<GetArchivedStoriesRequested>(_onGetArchivedStoriesRequested);
    on<ViewStoryRequested>(_onViewStoryRequested);
    on<ReplyToStoryRequested>(_onReplyToStoryRequested);
    on<GetStoryViewersRequested>(_onGetStoryViewersRequested);
    on<DeleteStoryRequested>(_onDeleteStoryRequested);
    on<CreateHighlightRequested>(_onCreateHighlightRequested);
    on<GetUserHighlightsRequested>(_onGetUserHighlightsRequested);
    on<UpdateHighlightRequested>(_onUpdateHighlightRequested);
    on<DeleteHighlightRequested>(_onDeleteHighlightRequested);
  }

  Future<void> _onGetFollowingStoriesRequested(GetFollowingStoriesRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      final stories = await storyRepository.getFollowingStories();
      emit(StoryLoaded(userStories: stories));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateStoryRequested(CreateStoryRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      await storyRepository.createStory(media: event.media, caption: event.caption);
      emit(const StoryActionSuccess(message: 'Story created successfully'));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetUserActiveStoriesRequested(GetUserActiveStoriesRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      final stories = await storyRepository.getUserActiveStories(userId: event.userId);
      emit(UserActiveStoriesLoaded(stories: stories));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetArchivedStoriesRequested(GetArchivedStoriesRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      final response = await storyRepository.getArchivedStories(page: event.page, limit: event.limit);
      emit(ArchivedStoriesLoaded(response: response));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onViewStoryRequested(ViewStoryRequested event, Emitter<StoryState> emit) async {
    try {
      await storyRepository.viewStory(id: event.storyId);
    } catch (_) {}
  }

  Future<void> _onReplyToStoryRequested(ReplyToStoryRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      await storyRepository.replyToStory(id: event.storyId, text: event.text);
      emit(const StoryActionSuccess(message: 'Replied to story successfully'));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetStoryViewersRequested(GetStoryViewersRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      final viewers = await storyRepository.getStoryViewers(id: event.storyId);
      emit(StoryViewersLoaded(viewers: viewers));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteStoryRequested(DeleteStoryRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      await storyRepository.deleteStory(id: event.storyId);
      emit(const StoryActionSuccess(message: 'Story deleted successfully'));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateHighlightRequested(CreateHighlightRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      final highlight = await storyRepository.createHighlight(
        title: event.title,
        storyIds: event.storyIds,
        coverImage: event.coverImage,
      );
      emit(StoryHighlightActionSuccess(highlight: highlight, message: 'Highlight created successfully'));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetUserHighlightsRequested(GetUserHighlightsRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      final highlights = await storyRepository.getUserHighlights(userId: event.userId);
      emit(StoryHighlightsLoaded(highlights: highlights));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateHighlightRequested(UpdateHighlightRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      final highlight = await storyRepository.updateHighlight(
        id: event.highlightId,
        title: event.title,
        storyIds: event.storyIds,
      );
      emit(StoryHighlightActionSuccess(highlight: highlight, message: 'Highlight updated successfully'));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteHighlightRequested(DeleteHighlightRequested event, Emitter<StoryState> emit) async {
    emit(const StoryLoading());
    try {
      await storyRepository.deleteHighlight(id: event.highlightId);
      emit(const StoryActionSuccess(message: 'Highlight deleted successfully'));
    } catch (e) {
      emit(StoryFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
