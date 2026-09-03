import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/features/comment/domain/entities/comment.dart';
import 'package:vagabond/features/comment/domain/repositories/comment_repository.dart';
import 'package:vagabond/features/comment/presentation/bloc/comment_event.dart';
import 'package:vagabond/features/comment/presentation/bloc/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepository;

  CommentBloc({required this.commentRepository}) : super(const CommentInitial()) {
    on<GetCommentsRequested>(_onGetCommentsRequested);
    on<GetRepliesRequested>(_onGetRepliesRequested);
    on<CreateCommentRequested>(_onCreateCommentRequested);
    on<UpdateCommentRequested>(_onUpdateCommentRequested);
    on<DeleteCommentRequested>(_onDeleteCommentRequested);
    on<LikeCommentRequested>(_onLikeCommentRequested);
    on<DislikeCommentRequested>(_onDislikeCommentRequested);
  }

  Future<void> _onGetCommentsRequested(GetCommentsRequested event, Emitter<CommentState> emit) async {
    final currentState = state;
    if (event.isRefresh || currentState is! CommentsLoaded) {
      emit(const CommentsLoading());
      try {
        final response = await commentRepository.getPostComments(postId: event.postId, page: 1, limit: event.limit);
        emit(
          CommentsLoaded(
            comments: response.comments,
            currentPage: response.currentPage,
            totalPages: response.totalPages,
            totalComments: response.totalComments,
            hasReachedMax: response.currentPage >= response.totalPages,
          ),
        );
      } catch (e) {
        emit(CommentsFailure(error: e.toString()));
      }
    } else {
      if (currentState.hasReachedMax) return;
      try {
        final nextPage = currentState.currentPage + 1;
        final response = await commentRepository.getPostComments(
          postId: event.postId,
          page: nextPage,
          limit: event.limit,
        );
        emit(
          currentState.copyWith(
            comments: List.of(currentState.comments)..addAll(response.comments),
            currentPage: response.currentPage,
            totalPages: response.totalPages,
            totalComments: response.totalComments,
            hasReachedMax: response.currentPage >= response.totalPages,
          ),
        );
      } catch (e) {
        emit(CommentsFailure(error: e.toString()));
      }
    }
  }

  Future<void> _onGetRepliesRequested(GetRepliesRequested event, Emitter<CommentState> emit) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    final loadingReplies = Set<String>.from(currentState.loadingReplies)..add(event.commentId);
    emit(currentState.copyWith(loadingReplies: loadingReplies));

    try {
      final currentRepliesPage = currentState.repliesCurrentPage[event.commentId] ?? 0;
      final nextPage = currentRepliesPage + 1;

      final response = await commentRepository.getCommentReplies(
        commentId: event.commentId,
        page: nextPage,
        limit: event.limit,
      );

      final updatedRepliesList = List<Comment>.from(currentState.replies[event.commentId] ?? [])
        ..addAll(response.replies);

      final updatedReplies = Map<String, List<Comment>>.from(currentState.replies)
        ..[event.commentId] = updatedRepliesList;

      final updatedRepliesCurrentPage = Map<String, int>.from(currentState.repliesCurrentPage)
        ..[event.commentId] = response.currentPage;

      final updatedRepliesTotalPages = Map<String, int>.from(currentState.repliesTotalPages)
        ..[event.commentId] = response.totalPages;

      final updatedLoadingReplies = Set<String>.from(currentState.loadingReplies)..remove(event.commentId);

      emit(
        currentState.copyWith(
          replies: updatedReplies,
          repliesCurrentPage: updatedRepliesCurrentPage,
          repliesTotalPages: updatedRepliesTotalPages,
          loadingReplies: updatedLoadingReplies,
        ),
      );
    } catch (e) {
      final updatedLoadingReplies = Set<String>.from(currentState.loadingReplies)..remove(event.commentId);
      emit(currentState.copyWith(loadingReplies: updatedLoadingReplies));
    }
  }

  Future<void> _onCreateCommentRequested(CreateCommentRequested event, Emitter<CommentState> emit) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    emit(
      CommentActionLoading(
        comments: currentState.comments,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        totalComments: currentState.totalComments,
        hasReachedMax: currentState.hasReachedMax,
        replies: currentState.replies,
        repliesCurrentPage: currentState.repliesCurrentPage,
        repliesTotalPages: currentState.repliesTotalPages,
        loadingReplies: currentState.loadingReplies,
      ),
    );

    try {
      final newComment = await commentRepository.createComment(
        postId: event.postId,
        text: event.text,
        parentCommentId: event.parentCommentId,
      );

      List<Comment> updatedComments = currentState.comments;
      int updatedTotalComments = currentState.totalComments;
      Map<String, List<Comment>> updatedReplies = currentState.replies;

      if (event.parentCommentId == null) {
        // Top-level comment
        updatedComments = List<Comment>.from(currentState.comments)..insert(0, newComment);
        updatedTotalComments = currentState.totalComments + 1;
      } else {
        // Reply comment
        final parentId = event.parentCommentId!;

        // Update replies list
        final updatedRepliesList = List<Comment>.from(currentState.replies[parentId] ?? [])..add(newComment);
        updatedReplies = Map<String, List<Comment>>.from(currentState.replies)..[parentId] = updatedRepliesList;

        // Increment repliesCount on the parent comment
        updatedComments = currentState.comments.map((comment) {
          if (comment.id == parentId) {
            return comment.copyWith(repliesCount: comment.repliesCount + 1);
          }
          return comment;
        }).toList();
      }

      emit(
        CommentActionSuccess(
          message: event.parentCommentId == null ? 'Comment posted successfully' : 'Reply posted successfully',
          comment: newComment,
          comments: updatedComments,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          totalComments: updatedTotalComments,
          hasReachedMax: currentState.hasReachedMax,
          replies: updatedReplies,
          repliesCurrentPage: currentState.repliesCurrentPage,
          repliesTotalPages: currentState.repliesTotalPages,
          loadingReplies: currentState.loadingReplies,
        ),
      );
    } catch (e) {
      emit(
        CommentActionFailure(
          error: e.toString(),
          comments: currentState.comments,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          totalComments: currentState.totalComments,
          hasReachedMax: currentState.hasReachedMax,
          replies: currentState.replies,
          repliesCurrentPage: currentState.repliesCurrentPage,
          repliesTotalPages: currentState.repliesTotalPages,
          loadingReplies: currentState.loadingReplies,
        ),
      );
    }
  }

  Future<void> _onUpdateCommentRequested(UpdateCommentRequested event, Emitter<CommentState> emit) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    emit(
      CommentActionLoading(
        comments: currentState.comments,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        totalComments: currentState.totalComments,
        hasReachedMax: currentState.hasReachedMax,
        replies: currentState.replies,
        repliesCurrentPage: currentState.repliesCurrentPage,
        repliesTotalPages: currentState.repliesTotalPages,
        loadingReplies: currentState.loadingReplies,
      ),
    );

    try {
      final updatedComment = await commentRepository.updateComment(commentId: event.commentId, text: event.text);

      // Update in top-level comments
      final updatedComments = currentState.comments.map((comment) {
        if (comment.id == event.commentId) {
          return comment.copyWith(text: updatedComment.text);
        }
        return comment;
      }).toList();

      // Update in replies
      final updatedReplies = Map<String, List<Comment>>.from(currentState.replies);
      for (final entry in updatedReplies.entries) {
        final repliesList = entry.value;
        final index = repliesList.indexWhere((r) => r.id == event.commentId);
        if (index != -1) {
          final updatedRepliesList = List<Comment>.from(repliesList);
          updatedRepliesList[index] = updatedRepliesList[index].copyWith(text: updatedComment.text);
          updatedReplies[entry.key] = updatedRepliesList;
          break;
        }
      }

      emit(
        CommentActionSuccess(
          message: 'Comment updated successfully',
          comment: updatedComment,
          comments: updatedComments,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          totalComments: currentState.totalComments,
          hasReachedMax: currentState.hasReachedMax,
          replies: updatedReplies,
          repliesCurrentPage: currentState.repliesCurrentPage,
          repliesTotalPages: currentState.repliesTotalPages,
          loadingReplies: currentState.loadingReplies,
        ),
      );
    } catch (e) {
      emit(
        CommentActionFailure(
          error: e.toString(),
          comments: currentState.comments,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          totalComments: currentState.totalComments,
          hasReachedMax: currentState.hasReachedMax,
          replies: currentState.replies,
          repliesCurrentPage: currentState.repliesCurrentPage,
          repliesTotalPages: currentState.repliesTotalPages,
          loadingReplies: currentState.loadingReplies,
        ),
      );
    }
  }

  Future<void> _onDeleteCommentRequested(DeleteCommentRequested event, Emitter<CommentState> emit) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    emit(
      CommentActionLoading(
        comments: currentState.comments,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        totalComments: currentState.totalComments,
        hasReachedMax: currentState.hasReachedMax,
        replies: currentState.replies,
        repliesCurrentPage: currentState.repliesCurrentPage,
        repliesTotalPages: currentState.repliesTotalPages,
        loadingReplies: currentState.loadingReplies,
      ),
    );

    try {
      final message = await commentRepository.deleteComment(commentId: event.commentId);

      List<Comment> updatedComments = currentState.comments;
      int updatedTotalComments = currentState.totalComments;
      Map<String, List<Comment>> updatedReplies = currentState.replies;

      // Check if it is a top-level comment
      final isTopLevel = currentState.comments.any((c) => c.id == event.commentId);

      if (isTopLevel) {
        updatedComments = currentState.comments.where((c) => c.id != event.commentId).toList();
        updatedTotalComments = currentState.totalComments - 1;
      } else {
        // It's a reply. Find the parent comment and decrement its repliesCount.
        String? parentId;
        updatedReplies = Map<String, List<Comment>>.from(currentState.replies);

        for (final entry in updatedReplies.entries) {
          final repliesList = entry.value;
          final index = repliesList.indexWhere((r) => r.id == event.commentId);
          if (index != -1) {
            parentId = entry.key;
            final updatedRepliesList = List<Comment>.from(repliesList)..removeAt(index);
            updatedReplies[parentId] = updatedRepliesList;
            break;
          }
        }

        if (parentId != null) {
          updatedComments = currentState.comments.map((comment) {
            if (comment.id == parentId) {
              return comment.copyWith(repliesCount: comment.repliesCount - 1);
            }
            return comment;
          }).toList();
        }
      }

      emit(
        CommentActionSuccess(
          message: message,
          comments: updatedComments,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          totalComments: updatedTotalComments,
          hasReachedMax: currentState.hasReachedMax,
          replies: updatedReplies,
          repliesCurrentPage: currentState.repliesCurrentPage,
          repliesTotalPages: currentState.repliesTotalPages,
          loadingReplies: currentState.loadingReplies,
        ),
      );
    } catch (e) {
      emit(
        CommentActionFailure(
          error: e.toString(),
          comments: currentState.comments,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          totalComments: currentState.totalComments,
          hasReachedMax: currentState.hasReachedMax,
          replies: currentState.replies,
          repliesCurrentPage: currentState.repliesCurrentPage,
          repliesTotalPages: currentState.repliesTotalPages,
          loadingReplies: currentState.loadingReplies,
        ),
      );
    }
  }

  Future<void> _onLikeCommentRequested(LikeCommentRequested event, Emitter<CommentState> emit) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    try {
      final result = await commentRepository.likeComment(commentId: event.commentId);

      // Update in top-level comments
      final updatedComments = currentState.comments.map((comment) {
        if (comment.id == event.commentId) {
          return comment.copyWith(
            likesCount: result.likesCount,
            dislikesCount: result.dislikesCount,
            hasLiked: result.hasLiked,
            hasDisliked: result.hasDisliked,
          );
        }
        return comment;
      }).toList();

      // Update in replies
      final updatedReplies = Map<String, List<Comment>>.from(currentState.replies);
      for (final entry in updatedReplies.entries) {
        final repliesList = entry.value;
        final index = repliesList.indexWhere((r) => r.id == event.commentId);
        if (index != -1) {
          final updatedRepliesList = List<Comment>.from(repliesList);
          updatedRepliesList[index] = updatedRepliesList[index].copyWith(
            likesCount: result.likesCount,
            dislikesCount: result.dislikesCount,
            hasLiked: result.hasLiked,
            hasDisliked: result.hasDisliked,
          );
          updatedReplies[entry.key] = updatedRepliesList;
          break;
        }
      }

      emit(currentState.copyWith(comments: updatedComments, replies: updatedReplies));
    } catch (_) {
      // Fail silently for likes/dislikes to not interrupt user experience
    }
  }

  Future<void> _onDislikeCommentRequested(DislikeCommentRequested event, Emitter<CommentState> emit) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    try {
      final result = await commentRepository.dislikeComment(commentId: event.commentId);

      // Update in top-level comments
      final updatedComments = currentState.comments.map((comment) {
        if (comment.id == event.commentId) {
          return comment.copyWith(
            likesCount: result.likesCount,
            dislikesCount: result.dislikesCount,
            hasLiked: result.hasLiked,
            hasDisliked: result.hasDisliked,
          );
        }
        return comment;
      }).toList();

      // Update in replies
      final updatedReplies = Map<String, List<Comment>>.from(currentState.replies);
      for (final entry in updatedReplies.entries) {
        final repliesList = entry.value;
        final index = repliesList.indexWhere((r) => r.id == event.commentId);
        if (index != -1) {
          final updatedRepliesList = List<Comment>.from(repliesList);
          updatedRepliesList[index] = updatedRepliesList[index].copyWith(
            likesCount: result.likesCount,
            dislikesCount: result.dislikesCount,
            hasLiked: result.hasLiked,
            hasDisliked: result.hasDisliked,
          );
          updatedReplies[entry.key] = updatedRepliesList;
          break;
        }
      }

      emit(currentState.copyWith(comments: updatedComments, replies: updatedReplies));
    } catch (_) {
      // Fail silently for likes/dislikes to not interrupt user experience
    }
  }
}
