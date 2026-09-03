import 'package:vagabond/features/comment/domain/entities/comment.dart';

class CommentUserModel extends CommentUser {
  const CommentUserModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.profilePicture,
    super.accountType,
    super.isVerified,
  });

  factory CommentUserModel.fromJson(Map<String, dynamic> json) {
    final rawProfilePicture = json['profilePicture'];
    String profilePicUrl = '';
    if (rawProfilePicture is Map) {
      profilePicUrl = rawProfilePicture['url'] ?? '';
    } else if (rawProfilePicture is String) {
      profilePicUrl = rawProfilePicture;
    }

    return CommentUserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePicture: profilePicUrl,
      accountType: json['accountType'],
      isVerified: json['isVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'accountType': accountType,
      'isVerified': isVerified,
    };
  }
}

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.post,
    required super.user,
    required super.text,
    super.parentComment,
    super.depth,
    super.likes,
    super.dislikes,
    required super.likesCount,
    required super.dislikesCount,
    required super.repliesCount,
    required super.hasLiked,
    required super.hasDisliked,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? json['id'] ?? '',
      post: json['post'] ?? '',
      user: CommentUserModel.fromJson(json['user'] ?? {}),
      text: json['text'] ?? '',
      parentComment: json['parentComment'] is Map ? json['parentComment']['_id'] : json['parentComment'],
      depth: json['depth'],
      likes: (json['likes'] as List?)?.map((e) => e.toString()).toList(),
      dislikes: (json['dislikes'] as List?)?.map((e) => e.toString()).toList(),
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      repliesCount: json['repliesCount'] ?? 0,
      hasLiked: json['hasLiked'] ?? false,
      hasDisliked: json['hasDisliked'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'post': post,
      'user': (user as CommentUserModel).toJson(),
      'text': text,
      'parentComment': parentComment,
      'depth': depth,
      'likes': likes,
      'dislikes': dislikes,
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'repliesCount': repliesCount,
      'hasLiked': hasLiked,
      'hasDisliked': hasDisliked,
      'createdAt': createdAt,
    };
  }
}

class PostCommentsResponseModel extends PostCommentsResponse {
  const PostCommentsResponseModel({
    required List<CommentModel> super.comments,
    required super.currentPage,
    required super.totalPages,
    required super.totalComments,
  });

  factory PostCommentsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return PostCommentsResponseModel(
      comments: (data['comments'] as List? ?? []).map((item) => CommentModel.fromJson(item)).toList(),
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      totalComments: data['totalComments'] ?? 0,
    );
  }
}

class CommentRepliesResponseModel extends CommentRepliesResponse {
  const CommentRepliesResponseModel({
    required List<CommentModel> super.replies,
    required super.currentPage,
    required super.totalPages,
    required super.totalReplies,
  });

  factory CommentRepliesResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return CommentRepliesResponseModel(
      replies: (data['replies'] as List? ?? []).map((item) => CommentModel.fromJson(item)).toList(),
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      totalReplies: data['totalReplies'] ?? 0,
    );
  }
}

class CommentLikeDislikeResultModel extends CommentLikeDislikeResult {
  const CommentLikeDislikeResultModel({
    required super.likesCount,
    required super.dislikesCount,
    required super.hasLiked,
    required super.hasDisliked,
  });

  factory CommentLikeDislikeResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return CommentLikeDislikeResultModel(
      likesCount: data['likesCount'] ?? 0,
      dislikesCount: data['dislikesCount'] ?? 0,
      hasLiked: data['hasLiked'] ?? false,
      hasDisliked: data['hasDisliked'] ?? false,
    );
  }
}

class CommentLikesDislikesUsersResponseModel extends CommentLikesDislikesUsersResponse {
  const CommentLikesDislikesUsersResponseModel({required List<CommentUserModel> super.users, required super.count});

  factory CommentLikesDislikesUsersResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return CommentLikesDislikesUsersResponseModel(
      users: (data['users'] as List? ?? []).map((item) => CommentUserModel.fromJson(item)).toList(),
      count: data['count'] ?? 0,
    );
  }
}
