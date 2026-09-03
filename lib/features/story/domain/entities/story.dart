class StoryMedia {
  final String publicId;
  final String url;
  final String type;

  const StoryMedia({required this.publicId, required this.url, required this.type});
}

class Story {
  final String id;
  final String userId;
  final StoryMedia media;
  final String caption;
  final int viewsCount;
  final bool hasViewed;
  final DateTime createdAt;
  final DateTime expiresAt;
  final StoryUser? user;

  const Story({
    required this.id,
    required this.userId,
    required this.media,
    required this.caption,
    required this.viewsCount,
    required this.hasViewed,
    required this.createdAt,
    required this.expiresAt,
    this.user,
  });
}

class StoryUser {
  final String id;
  final String username;
  final String fullName;
  final String profilePictureUrl;
  final String accountType;
  final bool isVerified;

  const StoryUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.profilePictureUrl,
    required this.accountType,
    required this.isVerified,
  });
}

class UserStories {
  final StoryUser user;
  final List<Story> stories;

  const UserStories({required this.user, required this.stories});
}

class StoryViewerInfo {
  final StoryUser user;
  final DateTime viewedAt;

  const StoryViewerInfo({required this.user, required this.viewedAt});
}

class StoryHighlight {
  final String id;
  final String userId;
  final String title;
  final String coverImageUrl;
  final List<Story> stories;
  final DateTime createdAt;

  const StoryHighlight({
    required this.id,
    required this.userId,
    required this.title,
    required this.coverImageUrl,
    required this.stories,
    required this.createdAt,
  });
}

class ArchivedStoriesResponse {
  final List<Story> stories;
  final int currentPage;
  final int totalPages;
  final int totalStories;

  const ArchivedStoriesResponse({
    required this.stories,
    required this.currentPage,
    required this.totalPages,
    required this.totalStories,
  });
}
