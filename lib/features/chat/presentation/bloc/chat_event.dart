import 'dart:io';
import 'package:vagabond/features/chat/domain/entities/chat.dart';

abstract class ChatEvent {
  const ChatEvent();
}

class ConnectSocketRequested extends ChatEvent {
  final String token;
  const ConnectSocketRequested({required this.token});
}

class DisconnectSocketRequested extends ChatEvent {
  const DisconnectSocketRequested();
}

class GetOrCreateChatRequested extends ChatEvent {
  final String userId;
  const GetOrCreateChatRequested({required this.userId});
}

class GetInboxChatsRequested extends ChatEvent {
  const GetInboxChatsRequested();
}

class GetChatMessagesRequested extends ChatEvent {
  final String chatId;
  final int page;
  final Chat? chat;
  const GetChatMessagesRequested({required this.chatId, this.page = 1, this.chat});
}

class SendTextMessageRequested extends ChatEvent {
  final String chatId;
  final String text;
  final String? sharedPostId;
  final String? sharedStoryId;

  const SendTextMessageRequested({required this.chatId, required this.text, this.sharedPostId, this.sharedStoryId});
}

class SendMediaMessageRequested extends ChatEvent {
  final String chatId;
  final File media;
  final String? text;

  const SendMediaMessageRequested({required this.chatId, required this.media, this.text});
}

class AcceptMessageRequestRequested extends ChatEvent {
  final String chatId;
  const AcceptMessageRequestRequested({required this.chatId});
}

class DeclineMessageRequestRequested extends ChatEvent {
  final String chatId;
  const DeclineMessageRequestRequested({required this.chatId});
}

class MarkMessagesReadRequested extends ChatEvent {
  final String chatId;
  const MarkMessagesReadRequested({required this.chatId});
}

class ReactMessageRequested extends ChatEvent {
  final String messageId;
  final String emoji;
  final String userId;
  final String username;
  final String fullName;
  const ReactMessageRequested({
    required this.messageId,
    required this.emoji,
    required this.userId,
    required this.username,
    required this.fullName,
  });
}

class DeleteMessageRequested extends ChatEvent {
  final String messageId;
  const DeleteMessageRequested({required this.messageId});
}

class TypingStatusChanged extends ChatEvent {
  final String chatId;
  final bool isTyping;
  const TypingStatusChanged({required this.chatId, required this.isTyping});
}

// Socket Event updates
class MessageReceived extends ChatEvent {
  final Message message;
  const MessageReceived({required this.message});
}

class MessageReadUpdateReceived extends ChatEvent {
  final String chatId;
  final String readBy;
  const MessageReadUpdateReceived({required this.chatId, required this.readBy});
}

class MessageReactedUpdateReceived extends ChatEvent {
  final String messageId;
  final List<MessageReaction> reactions;
  const MessageReactedUpdateReceived({required this.messageId, required this.reactions});
}

class MessageDeletedUpdateReceived extends ChatEvent {
  final String messageId;
  const MessageDeletedUpdateReceived({required this.messageId});
}

class UserTypingUpdateReceived extends ChatEvent {
  final String chatId;
  final String userId;
  final bool isTyping;
  const UserTypingUpdateReceived({required this.chatId, required this.userId, required this.isTyping});
}

class UserPresenceUpdateReceived extends ChatEvent {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;
  const UserPresenceUpdateReceived({required this.userId, required this.isOnline, this.lastSeen});
}
