import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/core/di/injection_container.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/comment/domain/entities/comment.dart';
import 'package:vagabond/features/comment/presentation/bloc/comment_bloc.dart';
import 'package:vagabond/features/comment/presentation/bloc/comment_event.dart';
import 'package:vagabond/features/comment/presentation/bloc/comment_state.dart';
import 'package:vagabond/features/comment/presentation/widgets/comment_tile.dart';
import 'package:vagabond/features/comment/presentation/widgets/comment_sheet_header.dart';
import 'package:vagabond/features/comment/presentation/widgets/comment_error_widget.dart';
import 'package:vagabond/features/comment/presentation/widgets/comment_input_area.dart';

class CommentsSheet extends StatefulWidget {
  final String postId;

  const CommentsSheet({super.key, required this.postId});

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => BlocProvider<CommentBloc>(
        create: (context) => sl<CommentBloc>()..add(GetCommentsRequested(postId: postId)),
        child: CommentsSheet(postId: postId),
      ),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  Comment? _replyingTo;
  Comment? _editingComment;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final bloc = context.read<CommentBloc>();
      if (bloc.state is CommentsLoaded) {
        final state = bloc.state as CommentsLoaded;
        if (!state.hasReachedMax) {
          bloc.add(GetCommentsRequested(postId: widget.postId, isRefresh: false));
        }
      }
    }
  }

  void _handleSubmit() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final bloc = context.read<CommentBloc>();

    if (_editingComment != null) {
      bloc.add(UpdateCommentRequested(commentId: _editingComment!.id, text: text));
    } else {
      bloc.add(CreateCommentRequested(postId: widget.postId, text: text, parentCommentId: _replyingTo?.id));
    }

    _commentController.clear();
    _focusNode.unfocus();
    setState(() {
      _replyingTo = null;
      _editingComment = null;
    });
  }

  void _cancelAction() {
    _commentController.clear();
    _focusNode.unfocus();
    setState(() {
      _replyingTo = null;
      _editingComment = null;
    });
  }

  void _startReply(Comment comment) {
    setState(() {
      _replyingTo = comment;
      _editingComment = null;
    });
    _focusNode.requestFocus();
  }

  void _startEdit(Comment comment) {
    setState(() {
      _editingComment = comment;
      _replyingTo = null;
      _commentController.text = comment.text;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthBloc>().currentUser;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? MediaQuery.of(context).viewInsets.bottom
        : MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                const CommentSheetHeader(),
                const Divider(color: Colors.white10, height: 1),

                // Comments List
                Expanded(
                  child: BlocConsumer<CommentBloc, CommentState>(
                    listener: (context, state) {
                      if (state is CommentActionSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message), backgroundColor: const Color(0xFF6366F1)),
                        );
                      } else if (state is CommentActionFailure) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.redAccent));
                      }
                    },
                    builder: (context, state) {
                      if (state is CommentsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                          ),
                        );
                      }

                      if (state is CommentsFailure) {
                        return CommentErrorWidget(
                          error: state.error,
                          onRetry: () {
                            context.read<CommentBloc>().add(
                              GetCommentsRequested(postId: widget.postId, isRefresh: true),
                            );
                          },
                        );
                      }

                      if (state is CommentsLoaded) {
                        if (state.comments.isEmpty) {
                          return const Center(
                            child: Text(AppStrings.commentsNoComments, style: TextStyle(color: Colors.white54)),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: state.comments.length + (state.hasReachedMax ? 0 : 1),
                          itemBuilder: (context, index) {
                            if (index >= state.comments.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }

                            final comment = state.comments[index];
                            final replies = state.replies[comment.id] ?? [];
                            final isRepliesLoading = state.loadingReplies.contains(comment.id);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommentTile(
                                  comment: comment,
                                  currentUserId: currentUser?.id,
                                  onReply: () => _startReply(comment),
                                  onEdit: () => _startEdit(comment),
                                  onDelete: () {
                                    context.read<CommentBloc>().add(DeleteCommentRequested(commentId: comment.id));
                                  },
                                  onLike: () {
                                    context.read<CommentBloc>().add(LikeCommentRequested(commentId: comment.id));
                                  },
                                  onDislike: () {
                                    context.read<CommentBloc>().add(DislikeCommentRequested(commentId: comment.id));
                                  },
                                ),
                                // Replies List
                                if (replies.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 48.0),
                                    child: Column(
                                      children: replies.map((reply) {
                                        return CommentTile(
                                          comment: reply,
                                          currentUserId: currentUser?.id,
                                          isReply: true,
                                          onReply: () => _startReply(comment), // Reply to parent
                                          onEdit: () => _startEdit(reply),
                                          onDelete: () {
                                            context.read<CommentBloc>().add(
                                              DeleteCommentRequested(commentId: reply.id),
                                            );
                                          },
                                          onLike: () {
                                            context.read<CommentBloc>().add(LikeCommentRequested(commentId: reply.id));
                                          },
                                          onDislike: () {
                                            context.read<CommentBloc>().add(
                                              DislikeCommentRequested(commentId: reply.id),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                // View Replies Button
                                if (comment.repliesCount > 0 && replies.length < comment.repliesCount)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 56.0, bottom: 8.0),
                                    child: isRepliesLoading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                            ),
                                          )
                                        : TextButton(
                                            onPressed: () {
                                              context.read<CommentBloc>().add(
                                                GetRepliesRequested(commentId: comment.id),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text(
                                              replies.isEmpty
                                                  ? '${AppStrings.commentsViewReplies} ${comment.repliesCount}'
                                                  : AppStrings.commentsViewMoreReplies,
                                              style: const TextStyle(
                                                color: Color(0xFF818CF8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                  ),
                              ],
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // Input Field Area
                CommentInputArea(
                  bottomPadding: bottomPadding,
                  replyingTo: _replyingTo,
                  editingComment: _editingComment,
                  onCancelAction: _cancelAction,
                  onSubmit: _handleSubmit,
                  commentController: _commentController,
                  focusNode: _focusNode,
                  currentUser: currentUser,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
