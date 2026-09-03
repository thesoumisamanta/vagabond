import 'package:vagabond/features/comment/domain/entities/comment.dart';

abstract class CommentState {
  const CommentState();
}

class CommentInitial extends CommentState {
  const CommentInitial();
}

class CommentsLoading extends CommentState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentState {
  final List<Comment> comments;
  final int currentPage;
  final int totalPages;
  final int totalComments;
  final bool hasReachedMax;
  final Map<String, List<Comment>> replies;
  final Map<String, int> repliesCurrentPage;
  final Map<String, int> repliesTotalPages;
  final Set<String> loadingReplies;

  const CommentsLoaded({
    required this.comments,
    required this.currentPage,
    required this.totalPages,
    required this.totalComments,
    required this.hasReachedMax,
    this.replies = const {},
    this.repliesCurrentPage = const {},
    this.repliesTotalPages = const {},
    this.loadingReplies = const {},
  });

  CommentsLoaded copyWith({
    List<Comment>? comments,
    int? currentPage,
    int? totalPages,
    int? totalComments,
    bool? hasReachedMax,
    Map<String, List<Comment>>? replies,
    Map<String, int>? repliesCurrentPage,
    Map<String, int>? repliesTotalPages,
    Set<String>? loadingReplies,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalComments: totalComments ?? this.totalComments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      replies: replies ?? this.replies,
      repliesCurrentPage: repliesCurrentPage ?? this.repliesCurrentPage,
      repliesTotalPages: repliesTotalPages ?? this.repliesTotalPages,
      loadingReplies: loadingReplies ?? this.loadingReplies,
    );
  }
}

class CommentsFailure extends CommentState {
  final String error;
  const CommentsFailure({required this.error});
}

class CommentActionLoading extends CommentsLoaded {
  const CommentActionLoading({
    required super.comments,
    required super.currentPage,
    required super.totalPages,
    required super.totalComments,
    required super.hasReachedMax,
    super.replies,
    super.repliesCurrentPage,
    super.repliesTotalPages,
    super.loadingReplies,
  });
}

class CommentActionSuccess extends CommentsLoaded {
  final String message;
  final Comment? comment;

  const CommentActionSuccess({
    required this.message,
    this.comment,
    required super.comments,
    required super.currentPage,
    required super.totalPages,
    required super.totalComments,
    required super.hasReachedMax,
    super.replies,
    super.repliesCurrentPage,
    super.repliesTotalPages,
    super.loadingReplies,
  });
}

class CommentActionFailure extends CommentsLoaded {
  final String error;

  const CommentActionFailure({
    required this.error,
    required super.comments,
    required super.currentPage,
    required super.totalPages,
    required super.totalComments,
    required super.hasReachedMax,
    super.replies,
    super.repliesCurrentPage,
    super.repliesTotalPages,
    super.loadingReplies,
  });
}
