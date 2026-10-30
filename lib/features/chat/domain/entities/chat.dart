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

  ChatParticipant copyWith({
    String? id,
    String? username,
    String? fullName,
    String? profilePicture,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return ChatParticipant(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
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

  const MessageReaction({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.emoji,
  });
}

class ReplyMessage {
  final String id;
  final String text;
  final String messageType;
  final String senderUsername;
  final String? senderFullName;

  const ReplyMessage({
    required this.id,
    required this.text,
    required this.messageType,
    required this.senderUsername,
    this.senderFullName,
  });
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
  final String status; // 'sending' | 'sent' | 'delivered' | 'read'
  final ReplyMessage? replyTo;

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
    this.status = 'sent',
    this.replyTo,
  });

  Message copyWith({
    String? id,
    String? chatId,
    ChatParticipant? sender,
    String? messageType,
    String? text,
    MessageMedia? media,
    String? sharedPostId,
    String? sharedStoryId,
    List<MessageReaction>? reactions,
    bool? isRead,
    bool? isDeleted,
    DateTime? createdAt,
    String? status,
    ReplyMessage? replyTo,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      messageType: messageType ?? this.messageType,
      text: text ?? this.text,
      media: media ?? this.media,
      sharedPostId: sharedPostId ?? this.sharedPostId,
      sharedStoryId: sharedStoryId ?? this.sharedStoryId,
      reactions: reactions ?? this.reactions,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      replyTo: replyTo ?? this.replyTo,
    );
  }
}

class Chat {
  final String id;
  final List<ChatParticipant> participants;
  final String status; // 'pending' | 'accepted' | 'declined'
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

  Chat copyWith({
    String? id,
    List<ChatParticipant>? participants,
    String? status,
    String? requestedBy,
    Map<String, int>? unreadCount,
    DateTime? lastMessageTime,
    Message? lastMessage,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
