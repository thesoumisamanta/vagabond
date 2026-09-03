import 'package:vagabond/features/story/domain/entities/story.dart';

class StoryMediaModel extends StoryMedia {
  const StoryMediaModel({required super.publicId, required super.url, required super.type});

  factory StoryMediaModel.fromJson(Map<String, dynamic> json) {
    return StoryMediaModel(
      publicId: json['public_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? 'image',
    );
  }
}

class StoryModel extends Story {
  const StoryModel({
    required super.id,
    required super.userId,
    required super.media,
    required super.caption,
    required super.viewsCount,
    required super.hasViewed,
    required super.createdAt,
    required super.expiresAt,
    super.user,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    StoryUserModel? parsedUser;
    if (userJson != null && userJson is Map<String, dynamic>) {
      parsedUser = StoryUserModel.fromJson(userJson);
    }

    return StoryModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['user'] is String
          ? json['user'] as String
          : (json['user'] as Map<String, dynamic>?)?['_id'] as String? ?? '',
      media: StoryMediaModel.fromJson(json['media'] as Map<String, dynamic>? ?? {}),
      caption: json['caption'] as String? ?? '',
      viewsCount: json['viewsCount'] as int? ?? 0,
      hasViewed: json['hasViewed'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ?? DateTime.now().add(const Duration(hours: 24)),
      user: parsedUser,
    );
  }
}

class StoryUserModel extends StoryUser {
  const StoryUserModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.profilePictureUrl,
    required super.accountType,
    required super.isVerified,
  });

  factory StoryUserModel.fromJson(Map<String, dynamic> json) {
    final pic = json['profilePicture'];
    final picUrl = pic is Map<String, dynamic> ? pic['url'] as String? ?? '' : pic as String? ?? '';

    return StoryUserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      profilePictureUrl: picUrl,
      accountType: json['accountType'] as String? ?? 'personal',
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}

class UserStoriesModel extends UserStories {
  const UserStoriesModel({required super.user, required super.stories});

  factory UserStoriesModel.fromJson(Map<String, dynamic> json) {
    final storiesJson = json['stories'] as List<dynamic>? ?? [];
    return UserStoriesModel(
      user: StoryUserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      stories: storiesJson.map((s) => StoryModel.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }
}

class StoryViewerInfoModel extends StoryViewerInfo {
  const StoryViewerInfoModel({required super.user, required super.viewedAt});

  factory StoryViewerInfoModel.fromJson(Map<String, dynamic> json) {
    return StoryViewerInfoModel(
      user: StoryUserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      viewedAt: DateTime.tryParse(json['viewedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class StoryHighlightModel extends StoryHighlight {
  const StoryHighlightModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.coverImageUrl,
    required super.stories,
    required super.createdAt,
  });

  factory StoryHighlightModel.fromJson(Map<String, dynamic> json) {
    final storiesJson = json['stories'] as List<dynamic>? ?? [];
    final coverImage = json['coverImage'];
    final coverImageUrl = coverImage is Map<String, dynamic>
        ? coverImage['url'] as String? ?? ''
        : coverImage as String? ?? '';

    return StoryHighlightModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['user'] is String
          ? json['user'] as String
          : (json['user'] as Map<String, dynamic>?)?['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      coverImageUrl: coverImageUrl,
      stories: storiesJson.map((s) => StoryModel.fromJson(s as Map<String, dynamic>)).toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ArchivedStoriesResponseModel extends ArchivedStoriesResponse {
  const ArchivedStoriesResponseModel({
    required List<StoryModel> super.stories,
    required super.currentPage,
    required super.totalPages,
    required super.totalStories,
  });

  factory ArchivedStoriesResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final storiesJson = data['stories'] as List<dynamic>? ?? [];
    return ArchivedStoriesResponseModel(
      stories: storiesJson.map((s) => StoryModel.fromJson(s as Map<String, dynamic>)).toList(),
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 1,
      totalStories: data['totalStories'] ?? 0,
    );
  }
}
