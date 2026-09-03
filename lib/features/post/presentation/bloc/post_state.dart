import 'package:vagabond/features/post/domain/entities/post.dart';

abstract class PostState {
  const PostState();
}

class PostInitial extends PostState {
  const PostInitial();
}

class PostLoading extends PostState {
  const PostLoading();
}

class PostSuccess extends PostState {
  final String message;
  const PostSuccess({required this.message});
}

class PostFailure extends PostState {
  final String error;
  const PostFailure({required this.error});
}

class FeedLoading extends PostState {
  const FeedLoading();
}

class FeedLoaded extends PostState {
  final List<Post> posts;
  final int currentPage;
  final int totalPages;
  final int totalPosts;
  final bool hasReachedMax;

  const FeedLoaded({
    required this.posts,
    required this.currentPage,
    required this.totalPages,
    required this.totalPosts,
    required this.hasReachedMax,
  });

  FeedLoaded copyWith({List<Post>? posts, int? currentPage, int? totalPages, int? totalPosts, bool? hasReachedMax}) {
    return FeedLoaded(
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalPosts: totalPosts ?? this.totalPosts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class FeedFailure extends PostState {
  final String error;
  const FeedFailure({required this.error});
}

class PostDetailsLoading extends PostState {
  const PostDetailsLoading();
}

class PostDetailsSuccess extends PostState {
  final Post post;
  const PostDetailsSuccess({required this.post});
}

class PostDetailsFailure extends PostState {
  final String error;
  const PostDetailsFailure({required this.error});
}
