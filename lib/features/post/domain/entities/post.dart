class PostUser {
  final String id;
  final String username;
  final String fullName;
  final String profilePicture;
  final String accountType;
  final bool isVerified;

  const PostUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.profilePicture,
    required this.accountType,
    required this.isVerified,
  });
}

class PostMedia {
  final String publicId;
  final String url;
  final String type;

  const PostMedia({required this.publicId, required this.url, required this.type});
}

class Post {
  final String id;
  final PostUser user;
  final String caption;
  final String postType;
  final List<PostMedia> media;
  final String location;
  final List<String> tags;
  final List<String> likes;
  final List<String> dislikes;
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool hasLiked;
  final bool hasDisliked;
  final bool isCommentEnabled;
  final String createdAt;
  final String updatedAt;

  const Post({
    required this.id,
    required this.user,
    required this.caption,
    required this.postType,
    required this.media,
    required this.location,
    required this.tags,
    required this.likes,
    required this.dislikes,
    required this.likesCount,
    required this.dislikesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    required this.hasLiked,
    required this.hasDisliked,
    required this.isCommentEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  Post copyWith({
    String? id,
    PostUser? user,
    String? caption,
    String? postType,
    List<PostMedia>? media,
    String? location,
    List<String>? tags,
    List<String>? likes,
    List<String>? dislikes,
    int? likesCount,
    int? dislikesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    bool? hasLiked,
    bool? hasDisliked,
    bool? isCommentEnabled,
    String? createdAt,
    String? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      caption: caption ?? this.caption,
      postType: postType ?? this.postType,
      media: media ?? this.media,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      hasLiked: hasLiked ?? this.hasLiked,
      hasDisliked: hasDisliked ?? this.hasDisliked,
      isCommentEnabled: isCommentEnabled ?? this.isCommentEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FeedResponse {
  final List<Post> posts;
  final int currentPage;
  final int totalPages;
  final int totalPosts;

  const FeedResponse({
    required this.posts,
    required this.currentPage,
    required this.totalPages,
    required this.totalPosts,
  });
}

class LikeDislikeResult {
  final int likesCount;
  final int dislikesCount;
  final bool hasLiked;
  final bool hasDisliked;

  const LikeDislikeResult({
    required this.likesCount,
    required this.dislikesCount,
    required this.hasLiked,
    required this.hasDisliked,
  });
}

class SharePostResult {
  final int sharesCount;

  const SharePostResult({required this.sharesCount});
}
