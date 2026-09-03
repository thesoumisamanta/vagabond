import 'package:vagabond/features/chat/domain/entities/chat.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class InboxChatsLoaded extends ChatState {
  final List<Chat> chats;
  const InboxChatsLoaded({required this.chats});
}

class ChatMessagesLoaded extends ChatState {
  final List<Message> messages;
  final String chatId;
  final bool hasReachedMax;
  final int currentPage;
  final Map<String, bool> typingUsers; // userId -> isTyping
  final Chat? chat;
  const ChatMessagesLoaded({
    required this.messages,
    required this.chatId,
    required this.hasReachedMax,
    required this.currentPage,
    required this.typingUsers,
    this.chat,
  });
}

class ChatSessionCreated extends ChatState {
  final Chat chat;
  const ChatSessionCreated({required this.chat});
}

class ChatActionSuccess extends ChatState {
  final String message;
  const ChatActionSuccess({required this.message});
}

class ChatFailure extends ChatState {
  final String error;
  const ChatFailure({required this.error});
}
