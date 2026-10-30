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

class JoinChatRequested extends ChatEvent {
  final String chatId;
  const JoinChatRequested({required this.chatId});
}

class LeaveChatRequested extends ChatEvent {
  final String chatId;
  const LeaveChatRequested({required this.chatId});
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
  final String? before;
  final bool isLoadMore;
  final Chat? chat;
  const GetChatMessagesRequested({
    required this.chatId,
    this.before,
    this.isLoadMore = false,
    this.chat,
  });
}

class SendTextMessageRequested extends ChatEvent {
  final String chatId;
  final String text;
  final String? replyToId;
  final String? sharedPostId;
  final String? sharedStoryId;

  const SendTextMessageRequested({
    required this.chatId,
    required this.text,
    this.replyToId,
    this.sharedPostId,
    this.sharedStoryId,
  });
}

class SendMediaMessageRequested extends ChatEvent {
  final String chatId;
  final File media;
  final String? text;
  final String? replyToId;
  final String? messageType;

  const SendMediaMessageRequested({
    required this.chatId,
    required this.media,
    this.text,
    this.replyToId,
    this.messageType,
  });
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

class ClearChatRequested extends ChatEvent {
  final String chatId;
  const ClearChatRequested({required this.chatId});
}

class SearchChatMessagesRequested extends ChatEvent {
  final String chatId;
  final String query;
  const SearchChatMessagesRequested({required this.chatId, required this.query});
}

class ClearSearchRequested extends ChatEvent {
  const ClearSearchRequested();
}

class TypingStatusChanged extends ChatEvent {
  final String chatId;
  final bool isTyping;
  const TypingStatusChanged({required this.chatId, required this.isTyping});
}

class CheckUserPresenceRequested extends ChatEvent {
  final String targetUserId;
  const CheckUserPresenceRequested({required this.targetUserId});
}

// Socket Event updates
class MessageReceived extends ChatEvent {
  final Message message;
  final String chatId;
  const MessageReceived({required this.message, required this.chatId});
}

class NewSentMessageReceived extends ChatEvent {
  final Message message;
  final String chatId;
  const NewSentMessageReceived({required this.message, required this.chatId});
}

class MessagesDeliveredReceived extends ChatEvent {
  final List<Map<String, dynamic>> deliveredMessages;
  const MessagesDeliveredReceived({required this.deliveredMessages});
}

class MessageReadUpdateReceived extends ChatEvent {
  final String chatId;
  final String readBy;
  const MessageReadUpdateReceived({required this.chatId, required this.readBy});
}

class MessageReactedUpdateReceived extends ChatEvent {
  final String messageId;
  final String chatId;
  final List<MessageReaction> reactions;
  const MessageReactedUpdateReceived({
    required this.messageId,
    required this.chatId,
    required this.reactions,
  });
}

class MessageDeletedUpdateReceived extends ChatEvent {
  final String messageId;
  final String chatId;
  const MessageDeletedUpdateReceived({required this.messageId, required this.chatId});
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

class ChatClearedReceived extends ChatEvent {
  final String chatId;
  const ChatClearedReceived({required this.chatId});
}

class ChatRequestAcceptedReceived extends ChatEvent {
  final String chatId;
  const ChatRequestAcceptedReceived({required this.chatId});
}

class ChatRequestDeclinedReceived extends ChatEvent {
  final String chatId;
  const ChatRequestDeclinedReceived({required this.chatId});
}

class InboxChatsRefreshed extends ChatEvent {
  final List<Chat> chats;
  const InboxChatsRefreshed({required this.chats});
}
