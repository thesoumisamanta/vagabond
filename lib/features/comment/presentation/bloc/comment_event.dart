abstract class CommentEvent {
  const CommentEvent();
}

class GetCommentsRequested extends CommentEvent {
  final String postId;
  final int page;
  final int limit;
  final bool isRefresh;

  const GetCommentsRequested({required this.postId, this.page = 1, this.limit = 20, this.isRefresh = false});
}

class GetRepliesRequested extends CommentEvent {
  final String commentId;
  final int page;
  final int limit;

  const GetRepliesRequested({required this.commentId, this.page = 1, this.limit = 10});
}

class CreateCommentRequested extends CommentEvent {
  final String postId;
  final String text;
  final String? parentCommentId;

  const CreateCommentRequested({required this.postId, required this.text, this.parentCommentId});
}

class UpdateCommentRequested extends CommentEvent {
  final String commentId;
  final String text;

  const UpdateCommentRequested({required this.commentId, required this.text});
}

class DeleteCommentRequested extends CommentEvent {
  final String commentId;

  const DeleteCommentRequested({required this.commentId});
}

class LikeCommentRequested extends CommentEvent {
  final String commentId;

  const LikeCommentRequested({required this.commentId});
}

class DislikeCommentRequested extends CommentEvent {
  final String commentId;

  const DislikeCommentRequested({required this.commentId});
}
