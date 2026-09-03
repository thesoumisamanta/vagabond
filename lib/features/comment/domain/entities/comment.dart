class CommentUser {
  final String id;
  final String username;
  final String fullName;
  final String profilePicture;
  final String? accountType;
  final bool? isVerified;

  const CommentUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.profilePicture,
    this.accountType,
    this.isVerified,
  });
}

class Comment {
  final String id;
  final String post;
  final CommentUser user;
  final String text;
  final String? parentComment;
  final int? depth;
  final List<String>? likes;
  final List<String>? dislikes;
  final int likesCount;
  final int dislikesCount;
  final int repliesCount;
  final bool hasLiked;
  final bool hasDisliked;
  final String createdAt;

  const Comment({
    required this.id,
    required this.post,
    required this.user,
    required this.text,
    this.parentComment,
    this.depth,
    this.likes,
    this.dislikes,
    required this.likesCount,
    required this.dislikesCount,
    required this.repliesCount,
    required this.hasLiked,
    required this.hasDisliked,
    required this.createdAt,
  });

  Comment copyWith({
    String? id,
    String? post,
    CommentUser? user,
    String? text,
    String? parentComment,
    int? depth,
    List<String>? likes,
    List<String>? dislikes,
    int? likesCount,
    int? dislikesCount,
    int? repliesCount,
    bool? hasLiked,
    bool? hasDisliked,
    String? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      post: post ?? this.post,
      user: user ?? this.user,
      text: text ?? this.text,
      parentComment: parentComment ?? this.parentComment,
      depth: depth ?? this.depth,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      hasLiked: hasLiked ?? this.hasLiked,
      hasDisliked: hasDisliked ?? this.hasDisliked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PostCommentsResponse {
  final List<Comment> comments;
  final int currentPage;
  final int totalPages;
  final int totalComments;

  const PostCommentsResponse({
    required this.comments,
    required this.currentPage,
    required this.totalPages,
    required this.totalComments,
  });
}

class CommentRepliesResponse {
  final List<Comment> replies;
  final int currentPage;
  final int totalPages;
  final int totalReplies;

  const CommentRepliesResponse({
    required this.replies,
    required this.currentPage,
    required this.totalPages,
    required this.totalReplies,
  });
}

class CommentLikeDislikeResult {
  final int likesCount;
  final int dislikesCount;
  final bool hasLiked;
  final bool hasDisliked;

  const CommentLikeDislikeResult({
    required this.likesCount,
    required this.dislikesCount,
    required this.hasLiked,
    required this.hasDisliked,
  });
}

class CommentLikesDislikesUsersResponse {
  final List<CommentUser> users;
  final int count;

  const CommentLikesDislikesUsersResponse({required this.users, required this.count});
}
