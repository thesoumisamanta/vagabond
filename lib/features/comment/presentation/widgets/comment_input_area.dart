import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/features/comment/domain/entities/comment.dart';
import 'package:vagabond/features/comment/presentation/bloc/comment_bloc.dart';
import 'package:vagabond/features/comment/presentation/bloc/comment_state.dart';

class CommentInputArea extends StatelessWidget {
  final double bottomPadding;
  final Comment? replyingTo;
  final Comment? editingComment;
  final VoidCallback onCancelAction;
  final VoidCallback onSubmit;
  final TextEditingController commentController;
  final FocusNode focusNode;
  final User? currentUser;

  const CommentInputArea({
    super.key,
    required this.bottomPadding,
    required this.replyingTo,
    required this.editingComment,
    required this.onCancelAction,
    required this.onSubmit,
    required this.commentController,
    required this.focusNode,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Replying/Editing Banner
          if (replyingTo != null || editingComment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.white.withOpacity(0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      replyingTo != null
                          ? '${AppStrings.commentsReplyingTo}${replyingTo!.user.username}'
                          : AppStrings.commentsEditingComment,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancelAction,
                    child: const Icon(Icons.close, color: Colors.white54, size: 16),
                  ),
                ],
              ),
            ),

          // Text Field Row
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              final isLoading = state is CommentActionLoading;
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Current user avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                      backgroundImage:
                          currentUser?.profilePictureUrl != null && currentUser!.profilePictureUrl.isNotEmpty
                          ? NetworkImage(currentUser!.profilePictureUrl)
                          : null,
                      child: currentUser?.profilePictureUrl == null || currentUser!.profilePictureUrl.isEmpty
                          ? Text(
                              currentUser?.fullName != null && currentUser!.fullName.isNotEmpty
                                  ? currentUser!.fullName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Text input
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: TextField(
                          controller: commentController,
                          focusNode: focusNode,
                          enabled: !isLoading,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          maxLines: 4,
                          minLines: 1,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          decoration: const InputDecoration(
                            hintText: AppStrings.commentsAddCommentHint,
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Send button
                    isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Color(0xFF6366F1)),
                            onPressed: onSubmit,
                          ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
