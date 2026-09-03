class ChatParticipant {
  final String id;
  final String username;
  final String fullName;
  final String profilePicture;
  final bool isOnline;
  final DateTime? lastSeen;

  const ChatParticipant({
    required this.id,
    required this.username,
    required this.fullName,
    required this.profilePicture,
    required this.isOnline,
    this.lastSeen,
  });
}

class MessageMedia {
  final String publicId;
  final String url;
  final String type;

  const MessageMedia({required this.publicId, required this.url, required this.type});
}

class MessageReaction {
  final String userId;
  final String username;
  final String fullName;
  final String emoji;

  const MessageReaction({required this.userId, required this.username, required this.fullName, required this.emoji});
}

class Message {
  final String id;
  final String chatId;
  final ChatParticipant sender;
  final String messageType;
  final String text;
  final MessageMedia? media;
  final String? sharedPostId;
  final String? sharedStoryId;
  final List<MessageReaction> reactions;
  final bool isRead;
  final bool isDeleted;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.messageType,
    required this.text,
    this.media,
    this.sharedPostId,
    this.sharedStoryId,
    required this.reactions,
    required this.isRead,
    required this.isDeleted,
    required this.createdAt,
  });
}

class Chat {
  final String id;
  final List<ChatParticipant> participants;
  final String status;
  final String? requestedBy;
  final Map<String, int> unreadCount;
  final DateTime lastMessageTime;
  final Message? lastMessage;

  const Chat({
    required this.id,
    required this.participants,
    required this.status,
    this.requestedBy,
    required this.unreadCount,
    required this.lastMessageTime,
    this.lastMessage,
  });
}
