import 'package:vagabond/features/post/domain/entities/post.dart';

class PostUserModel extends PostUser {
  const PostUserModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.profilePicture,
    required super.accountType,
    required super.isVerified,
  });

  factory PostUserModel.fromJson(Map<String, dynamic> json) {
    final rawProfilePicture = json['profilePicture'];
    String profilePicUrl = '';
    if (rawProfilePicture is Map) {
      profilePicUrl = rawProfilePicture['url'] ?? '';
    } else if (rawProfilePicture is String) {
      profilePicUrl = rawProfilePicture;
    }

    return PostUserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePicture: profilePicUrl,
      accountType: json['accountType'] ?? '',
      isVerified: json['isVerified'] ?? false,
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

class PostMediaModel extends PostMedia {
  const PostMediaModel({required super.publicId, required super.url, required super.type});

  factory PostMediaModel.fromJson(Map<String, dynamic> json) {
    return PostMediaModel(publicId: json['public_id'] ?? '', url: json['url'] ?? '', type: json['type'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'public_id': publicId, 'url': url, 'type': type};
  }
}

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.user,
    required super.caption,
    required super.postType,
    required super.media,
    required super.location,
    required super.tags,
    required super.likes,
    required super.dislikes,
    required super.likesCount,
    required super.dislikesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.viewsCount,
    required super.hasLiked,
    required super.hasDisliked,
    required super.isCommentEnabled,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'] ?? json['id'] ?? '',
      user: PostUserModel.fromJson(json['user'] ?? {}),
      caption: json['caption'] ?? '',
      postType: json['postType'] ?? '',
      media: (json['media'] as List? ?? []).map((item) => PostMediaModel.fromJson(item)).toList(),
      location: json['location'] ?? '',
      tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
      likes: (json['likes'] as List? ?? []).map((e) => e.toString()).toList(),
      dislikes: (json['dislikes'] as List? ?? []).map((e) => e.toString()).toList(),
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      viewsCount: json['viewsCount'] ?? 0,
      hasLiked: json['hasLiked'] ?? false,
      hasDisliked: json['hasDisliked'] ?? false,
      isCommentEnabled: json['isCommentEnabled'] ?? true,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': (user as PostUserModel).toJson(),
      'caption': caption,
      'postType': postType,
      'media': media.map((m) => (m as PostMediaModel).toJson()).toList(),
      'location': location,
      'tags': tags,
      'likes': likes,
      'dislikes': dislikes,
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewsCount': viewsCount,
      'hasLiked': hasLiked,
      'hasDisliked': hasDisliked,
      'isCommentEnabled': isCommentEnabled,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class FeedResponseModel extends FeedResponse {
  const FeedResponseModel({
    required List<PostModel> super.posts,
    required super.currentPage,
    required super.totalPages,
    required super.totalPosts,
  });

  factory FeedResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return FeedResponseModel(
      posts: (data['posts'] as List? ?? []).map((item) => PostModel.fromJson(item)).toList(),
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      totalPosts: data['totalPosts'] ?? 0,
    );
  }
}

class LikeDislikeResultModel extends LikeDislikeResult {
  const LikeDislikeResultModel({
    required super.likesCount,
    required super.dislikesCount,
    required super.hasLiked,
    required super.hasDisliked,
  });

  factory LikeDislikeResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LikeDislikeResultModel(
      likesCount: data['likesCount'] ?? 0,
      dislikesCount: data['dislikesCount'] ?? 0,
      hasLiked: data['hasLiked'] ?? false,
      hasDisliked: data['hasDisliked'] ?? false,
    );
  }
}

class SharePostResultModel extends SharePostResult {
  const SharePostResultModel({required super.sharesCount});

  factory SharePostResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return SharePostResultModel(sharesCount: data['sharesCount'] ?? 0);
  }
}
