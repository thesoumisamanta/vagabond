class NotificationSender {
  final String id;
  final String username;
  final String fullName;
  final String profilePicture;
  final bool isVerified;

  const NotificationSender({
    required this.id,
    required this.username,
    required this.fullName,
    required this.profilePicture,
    required this.isVerified,
  });
}

class NotificationPostMedia {
  final String url;
  final String type;

  const NotificationPostMedia({required this.url, required this.type});
}

class NotificationPost {
  final String id;
  final String caption;
  final List<NotificationPostMedia> media;

  const NotificationPost({required this.id, required this.caption, required this.media});
}

class NotificationEntity {
  final String id;
  final String recipient;
  final NotificationSender sender;
  final String type;
  final NotificationPost? post;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.recipient,
    required this.sender,
    required this.type,
    this.post,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });
}

class NotificationListResponse {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final int currentPage;
  final int totalPages;

  const NotificationListResponse({
    required this.notifications,
    required this.unreadCount,
    required this.currentPage,
    required this.totalPages,
  });
}
