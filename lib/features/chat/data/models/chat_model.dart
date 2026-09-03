import 'package:vagabond/features/chat/domain/entities/chat.dart';

class ChatParticipantModel extends ChatParticipant {
  const ChatParticipantModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.profilePicture,
    required super.isOnline,
    super.lastSeen,
  });

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) {
    String profilePicUrl = '';
    final profilePicJson = json['profilePicture'];
    if (profilePicJson != null) {
      if (profilePicJson is Map<String, dynamic>) {
        profilePicUrl = profilePicJson['url'] as String? ?? '';
      } else if (profilePicJson is String) {
        profilePicUrl = profilePicJson;
      }
    }

    return ChatParticipantModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      profilePicture: profilePicUrl,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.tryParse(json['lastSeen'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }
}

class MessageMediaModel extends MessageMedia {
  const MessageMediaModel({required super.publicId, required super.url, required super.type});

  factory MessageMediaModel.fromJson(Map<String, dynamic> json) {
    return MessageMediaModel(
      publicId: json['public_id'] as String? ?? json['publicId'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? 'image',
    );
  }

  Map<String, dynamic> toJson() {
    return {'public_id': publicId, 'url': url, 'type': type};
  }
}

class MessageReactionModel extends MessageReaction {
  const MessageReactionModel({
    required super.userId,
    required super.username,
    required super.fullName,
    required super.emoji,
  });

  factory MessageReactionModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    String uId = '';
    String uName = '';
    String fName = '';
    if (userJson != null) {
      if (userJson is Map<String, dynamic>) {
        uId = userJson['_id'] as String? ?? userJson['id'] as String? ?? '';
        uName = userJson['username'] as String? ?? '';
        fName = userJson['fullName'] as String? ?? '';
      } else if (userJson is String) {
        uId = userJson;
      }
    }
    return MessageReactionModel(userId: uId, username: uName, fullName: fName, emoji: json['emoji'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {'_id': userId, 'username': username, 'fullName': fullName},
      'emoji': emoji,
    };
  }
}

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.chatId,
    required super.sender,
    required super.messageType,
    required super.text,
    super.media,
    super.sharedPostId,
    super.sharedStoryId,
    required super.reactions,
    required super.isRead,
    required super.isDeleted,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderJson = json['sender'];
    ChatParticipantModel parsedSender;
    if (senderJson is Map<String, dynamic>) {
      parsedSender = ChatParticipantModel.fromJson(senderJson);
    } else {
      parsedSender = ChatParticipantModel(
        id: senderJson as String? ?? '',
        username: '',
        fullName: '',
        profilePicture: '',
        isOnline: false,
      );
    }

    final reactionsList = json['reactions'] as List? ?? [];
    final parsedReactions = reactionsList.map((r) {
      if (r is Map<String, dynamic>) {
        return MessageReactionModel.fromJson(r);
      } else {
        return MessageReactionModel(userId: r as String? ?? '', username: '', fullName: '', emoji: '');
      }
    }).toList();

    final mediaJson = json['media'];
    MessageMediaModel? parsedMedia;
    if (mediaJson != null && mediaJson is Map<String, dynamic>) {
      parsedMedia = MessageMediaModel.fromJson(mediaJson);
    }

    return MessageModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      chatId: json['chat'] as String? ?? '',
      sender: parsedSender,
      messageType: json['messageType'] as String? ?? 'text',
      text: json['text'] as String? ?? '',
      media: parsedMedia,
      sharedPostId: json['sharedPostId'] as String?,
      sharedStoryId: json['sharedStoryId'] as String?,
      reactions: parsedReactions,
      isRead: json['isRead'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chat': chatId,
      'sender': (sender as ChatParticipantModel).toJson(),
      'messageType': messageType,
      'text': text,
      if (media != null) 'media': (media as MessageMediaModel).toJson(),
      if (sharedPostId != null) 'sharedPostId': sharedPostId,
      if (sharedStoryId != null) 'sharedStoryId': sharedStoryId,
      'reactions': reactions.map((r) => (r as MessageReactionModel).toJson()).toList(),
      'isRead': isRead,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ChatModel extends Chat {
  const ChatModel({
    required super.id,
    required super.participants,
    required super.status,
    super.requestedBy,
    required super.unreadCount,
    required super.lastMessageTime,
    super.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final participantsList = json['participants'] as List? ?? [];
    final parsedParticipants = participantsList.map((p) {
      if (p is Map<String, dynamic>) {
        return ChatParticipantModel.fromJson(p);
      } else {
        return ChatParticipantModel(
          id: p as String? ?? '',
          username: '',
          fullName: '',
          profilePicture: '',
          isOnline: false,
        );
      }
    }).toList();

    final unreadMap = <String, int>{};
    final unreadJson = json['unreadCount'];
    if (unreadJson is Map<String, dynamic>) {
      unreadJson.forEach((key, value) {
        unreadMap[key] = value as int? ?? 0;
      });
    }

    final lastMsgJson = json['lastMessage'];
    MessageModel? parsedLastMsg;
    if (lastMsgJson != null && lastMsgJson is Map<String, dynamic>) {
      parsedLastMsg = MessageModel.fromJson(lastMsgJson);
    }

    return ChatModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      participants: parsedParticipants,
      status: json['status'] as String? ?? 'accepted',
      requestedBy: json['requestedBy'] as String?,
      unreadCount: unreadMap,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : DateTime.now(),
      lastMessage: parsedLastMsg,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants.map((p) => (p as ChatParticipantModel).toJson()).toList(),
      'status': status,
      if (requestedBy != null) 'requestedBy': requestedBy,
      'unreadCount': unreadCount,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      if (lastMessage != null) 'lastMessage': (lastMessage as MessageModel).toJson(),
    };
  }
}
