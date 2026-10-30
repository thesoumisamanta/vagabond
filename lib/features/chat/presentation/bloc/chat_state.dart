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
  final Map<String, bool> typingChats; // chatId -> isTyping

  const InboxChatsLoaded({required this.chats, this.typingChats = const {}});

  InboxChatsLoaded copyWith({
    List<Chat>? chats,
    Map<String, bool>? typingChats,
  }) {
    return InboxChatsLoaded(
      chats: chats ?? this.chats,
      typingChats: typingChats ?? this.typingChats,
    );
  }
}

class ChatMessagesLoaded extends ChatState {
  final List<Message> messages;
  final String chatId;
  final bool hasReachedMax;
  final String? nextCursor;
  final bool isLoadingMore;
  final Map<String, bool> typingUsers; // userId -> isTyping
  final Chat? chat;
  final List<Message>? searchResults;
  final bool isSearching;
  final String? searchQuery;
  final Map<String, bool> onlineUsers;
  final Map<String, DateTime?> lastSeenUsers;

  const ChatMessagesLoaded({
    required this.messages,
    required this.chatId,
    required this.hasReachedMax,
    this.nextCursor,
    this.isLoadingMore = false,
    required this.typingUsers,
    this.chat,
    this.searchResults,
    this.isSearching = false,
    this.searchQuery,
    this.onlineUsers = const {},
    this.lastSeenUsers = const {},
  });

  ChatMessagesLoaded copyWith({
    List<Message>? messages,
    String? chatId,
    bool? hasReachedMax,
    String? nextCursor,
    bool? isLoadingMore,
    Map<String, bool>? typingUsers,
    Chat? chat,
    List<Message>? searchResults,
    bool? isSearching,
    String? searchQuery,
    Map<String, bool>? onlineUsers,
    Map<String, DateTime?>? lastSeenUsers,
  }) {
    return ChatMessagesLoaded(
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      typingUsers: typingUsers ?? this.typingUsers,
      chat: chat ?? this.chat,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      lastSeenUsers: lastSeenUsers ?? this.lastSeenUsers,
    );
  }
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
