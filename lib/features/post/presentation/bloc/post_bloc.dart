import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/features/post/domain/entities/post.dart';
import 'package:vagabond/features/post/domain/repositories/post_repository.dart';
import 'package:vagabond/features/post/presentation/bloc/post_event.dart';
import 'package:vagabond/features/post/presentation/bloc/post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostBloc({required this.postRepository}) : super(const PostInitial()) {
    on<CreatePostRequested>(_onCreatePostRequested);
    on<GetFeedPostsRequested>(_onGetFeedPostsRequested);
    on<GetPostDetailsRequested>(_onGetPostDetailsRequested);
    on<LikePostRequested>(_onLikePostRequested);
    on<DislikePostRequested>(_onDislikePostRequested);
    on<SharePostRequested>(_onSharePostRequested);
  }

  Future<void> _onCreatePostRequested(CreatePostRequested event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    try {
      final message = await postRepository.createPost(
        media: event.media,
        caption: event.caption,
        location: event.location,
        tags: event.tags,
      );
      emit(PostSuccess(message: message));
    } catch (e) {
      emit(PostFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetFeedPostsRequested(GetFeedPostsRequested event, Emitter<PostState> emit) async {
    final currentState = state;
    List<Post> oldPosts = [];
    bool isRefresh = event.isRefresh;

    if (currentState is FeedLoaded && !isRefresh) {
      if (currentState.hasReachedMax) return;
      oldPosts = currentState.posts;
    }

    if (oldPosts.isEmpty || isRefresh) {
      emit(const FeedLoading());
    }

    try {
      final feedResponse = await postRepository.getFeedPosts(page: event.page, limit: event.limit);

      final posts = feedResponse.posts;
      final hasReachedMax = feedResponse.currentPage >= feedResponse.totalPages;

      emit(
        FeedLoaded(
          posts: isRefresh ? posts : (oldPosts + posts),
          currentPage: feedResponse.currentPage,
          totalPages: feedResponse.totalPages,
          totalPosts: feedResponse.totalPosts,
          hasReachedMax: hasReachedMax,
        ),
      );
    } catch (e) {
      emit(FeedFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetPostDetailsRequested(GetPostDetailsRequested event, Emitter<PostState> emit) async {
    emit(const PostDetailsLoading());
    try {
      final post = await postRepository.getPostDetails(id: event.id);
      emit(PostDetailsSuccess(post: post));
    } catch (e) {
      emit(PostDetailsFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLikePostRequested(LikePostRequested event, Emitter<PostState> emit) async {
    try {
      final result = await postRepository.likePost(id: event.id);
      _updatePostInState(event.id, result, emit);
    } catch (e) {
      // Silently fail or keep current state
    }
  }

  Future<void> _onDislikePostRequested(DislikePostRequested event, Emitter<PostState> emit) async {
    try {
      final result = await postRepository.dislikePost(id: event.id);
      _updatePostInState(event.id, result, emit);
    } catch (e) {
      // Silently fail or keep current state
    }
  }

  Future<void> _onSharePostRequested(SharePostRequested event, Emitter<PostState> emit) async {
    try {
      final result = await postRepository.sharePost(id: event.id);
      _updateShareCountInState(event.id, result, emit);
    } catch (e) {
      // Silently fail or keep current state
    }
  }

  void _updatePostInState(String id, LikeDislikeResult result, Emitter<PostState> emit) {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == id) {
          return post.copyWith(
            likesCount: result.likesCount,
            dislikesCount: result.dislikesCount,
            hasLiked: result.hasLiked,
            hasDisliked: result.hasDisliked,
          );
        }
        return post;
      }).toList();
      emit(currentState.copyWith(posts: updatedPosts));
    } else if (currentState is PostDetailsSuccess) {
      if (currentState.post.id == id) {
        emit(
          PostDetailsSuccess(
            post: currentState.post.copyWith(
              likesCount: result.likesCount,
              dislikesCount: result.dislikesCount,
              hasLiked: result.hasLiked,
              hasDisliked: result.hasDisliked,
            ),
          ),
        );
      }
    }
  }

  void _updateShareCountInState(String id, SharePostResult result, Emitter<PostState> emit) {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == id) {
          return post.copyWith(sharesCount: result.sharesCount);
        }
        return post;
      }).toList();
      emit(currentState.copyWith(posts: updatedPosts));
    } else if (currentState is PostDetailsSuccess) {
      if (currentState.post.id == id) {
        emit(PostDetailsSuccess(post: currentState.post.copyWith(sharesCount: result.sharesCount)));
      }
    }
  }
}
