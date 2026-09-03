import 'package:vagabond/features/notification/domain/entities/notification.dart';

class NotificationSenderModel extends NotificationSender {
  const NotificationSenderModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.profilePicture,
    required super.isVerified,
  });

  factory NotificationSenderModel.fromJson(Map<String, dynamic> json) {
    String profilePicUrl = '';
    final profilePicJson = json['profilePicture'];
    if (profilePicJson != null) {
      if (profilePicJson is Map<String, dynamic>) {
        profilePicUrl = profilePicJson['url'] as String? ?? '';
      } else if (profilePicJson is String) {
        profilePicUrl = profilePicJson;
      }
    }

    return NotificationSenderModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      profilePicture: profilePicUrl,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'isVerified': isVerified,
    };
  }
}

class NotificationPostMediaModel extends NotificationPostMedia {
  const NotificationPostMediaModel({required super.url, required super.type});

  factory NotificationPostMediaModel.fromJson(Map<String, dynamic> json) {
    return NotificationPostMediaModel(url: json['url'] as String? ?? '', type: json['type'] as String? ?? 'image');
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'type': type};
  }
}

class NotificationPostModel extends NotificationPost {
  const NotificationPostModel({required super.id, required super.caption, required super.media});

  factory NotificationPostModel.fromJson(Map<String, dynamic> json) {
    final mediaList = json['media'] as List? ?? [];
    final parsedMedia = mediaList.map((m) => NotificationPostMediaModel.fromJson(m as Map<String, dynamic>)).toList();

    return NotificationPostModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      media: parsedMedia,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'caption': caption,
      'media': media.map((m) => (m as NotificationPostMediaModel).toJson()).toList(),
    };
  }
}

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipient,
    required super.sender,
    required super.type,
    super.post,
    required super.message,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final senderJson = json['sender'] as Map<String, dynamic>? ?? {};
    final postJson = json['post'] as Map<String, dynamic>?;

    return NotificationModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      recipient: json['recipient'] as String? ?? '',
      sender: NotificationSenderModel.fromJson(senderJson),
      type: json['type'] as String? ?? '',
      post: postJson != null ? NotificationPostModel.fromJson(postJson) : null,
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'recipient': recipient,
      'sender': (sender as NotificationSenderModel).toJson(),
      'type': type,
      if (post != null) 'post': (post as NotificationPostModel).toJson(),
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class NotificationListResponseModel extends NotificationListResponse {
  const NotificationListResponseModel({
    required super.notifications,
    required super.unreadCount,
    required super.currentPage,
    required super.totalPages,
  });

  factory NotificationListResponseModel.fromJson(Map<String, dynamic> json) {
    final notificationsList = json['notifications'] as List? ?? [];
    final parsedNotifications = notificationsList
        .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
        .toList();

    return NotificationListResponseModel(
      notifications: parsedNotifications,
      unreadCount: json['unreadCount'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}
