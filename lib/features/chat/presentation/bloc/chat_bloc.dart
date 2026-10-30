import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/core/services/socket_service.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/domain/repositories/chat_repository.dart';
import 'package:vagabond/features/chat/data/models/chat_model.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_event.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final SocketService socketService;
  final List<StreamSubscription> _subscriptions = [];

  List<Chat> _cachedInboxChats = [];

  ChatBloc({required this.chatRepository, required this.socketService}) : super(const ChatInitial()) {
    on<ConnectSocketRequested>(_onConnectSocketRequested);
    on<DisconnectSocketRequested>(_onDisconnectSocketRequested);
    on<JoinChatRequested>(_onJoinChatRequested);
    on<LeaveChatRequested>(_onLeaveChatRequested);
    on<GetOrCreateChatRequested>(_onGetOrCreateChatRequested);
    on<GetInboxChatsRequested>(_onGetInboxChatsRequested);
    on<GetChatMessagesRequested>(_onGetChatMessagesRequested);
    on<SendTextMessageRequested>(_onSendTextMessageRequested);
    on<SendMediaMessageRequested>(_onSendMediaMessageRequested);
    on<AcceptMessageRequestRequested>(_onAcceptMessageRequestRequested);
    on<DeclineMessageRequestRequested>(_onDeclineMessageRequestRequested);
    on<MarkMessagesReadRequested>(_onMarkMessagesReadRequested);
    on<ReactMessageRequested>(_onReactMessageRequested);
    on<DeleteMessageRequested>(_onDeleteMessageRequested);
    on<ClearChatRequested>(_onClearChatRequested);
    on<SearchChatMessagesRequested>(_onSearchChatMessagesRequested);
    on<ClearSearchRequested>(_onClearSearchRequested);
    on<TypingStatusChanged>(_onTypingStatusChanged);
    on<CheckUserPresenceRequested>(_onCheckUserPresenceRequested);

    // Socket updates
    on<MessageReceived>(_onMessageReceived);
    on<NewSentMessageReceived>(_onNewSentMessageReceived);
    on<MessagesDeliveredReceived>(_onMessagesDeliveredReceived);
    on<MessageReadUpdateReceived>(_onMessageReadUpdateReceived);
    on<MessageReactedUpdateReceived>(_onMessageReactedUpdateReceived);
    on<MessageDeletedUpdateReceived>(_onMessageDeletedUpdateReceived);
    on<UserTypingUpdateReceived>(_onUserTypingUpdateReceived);
    on<UserPresenceUpdateReceived>(_onUserPresenceUpdateReceived);
    on<ChatClearedReceived>(_onChatClearedReceived);
    on<ChatRequestAcceptedReceived>(_onChatRequestAcceptedReceived);
    on<ChatRequestDeclinedReceived>(_onChatRequestDeclinedReceived);
    on<InboxChatsRefreshed>(_onInboxChatsRefreshed);
  }

  void _onConnectSocketRequested(ConnectSocketRequested event, Emitter<ChatState> emit) {
    _cancelSubscriptions();
    socketService.connect(event.token);

    // 1. receive_message
    _subscriptions.add(
      socketService.onMessageReceived.listen((data) {
        try {
          final msgJson = data['message'] as Map<String, dynamic>;
          final chatId = data['chatId'] as String? ?? msgJson['chat'] as String? ?? '';
          final message = MessageModel.fromJson(msgJson);
          add(MessageReceived(message: message, chatId: chatId));
        } catch (e) {
          debugPrint('Error parsing received message: $e');
        }
      }),
    );

    // 2. new_sent_message (multi-device sync)
    _subscriptions.add(
      socketService.onNewSentMessage.listen((data) {
        try {
          final msgJson = data['message'] as Map<String, dynamic>;
          final chatId = data['chatId'] as String? ?? msgJson['chat'] as String? ?? '';
          final message = MessageModel.fromJson(msgJson);
          add(NewSentMessageReceived(message: message, chatId: chatId));
        } catch (e) {
          debugPrint('Error parsing new_sent_message: $e');
        }
      }),
    );

    // 3. message_delivered
    _subscriptions.add(
      socketService.onMessageDelivered.listen((data) {
        try {
          final rawList = data['messages'] as List? ?? [];
          final delivered = rawList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          add(MessagesDeliveredReceived(deliveredMessages: delivered));
        } catch (e) {
          debugPrint('Error parsing message_delivered: $e');
        }
      }),
    );

    // 4. messages_read
    _subscriptions.add(
      socketService.onMessagesRead.listen((data) {
        final chatId = data['chatId'] as String? ?? '';
        final readBy = data['readBy'] as String? ?? '';
        add(MessageReadUpdateReceived(chatId: chatId, readBy: readBy));
      }),
    );

    // 5. message_reacted
    _subscriptions.add(
      socketService.onMessageReacted.listen((data) {
        final messageId = data['messageId'] as String? ?? '';
        final chatId = data['chatId'] as String? ?? '';
        final reactionsList = data['reactions'] as List? ?? [];
        final reactions = reactionsList.map((r) => MessageReactionModel.fromJson(r as Map<String, dynamic>)).toList();
        add(MessageReactedUpdateReceived(messageId: messageId, chatId: chatId, reactions: reactions));
      }),
    );

    // 6. message_deleted
    _subscriptions.add(
      socketService.onMessageDeleted.listen((data) {
        final messageId = data['messageId'] as String? ?? '';
        final chatId = data['chatId'] as String? ?? '';
        add(MessageDeletedUpdateReceived(messageId: messageId, chatId: chatId));
      }),
    );

    // 7. typing & stop_typing
    _subscriptions.add(
      socketService.onUserTyping.listen((data) {
        final chatId = data['chatId'] as String? ?? '';
        final userId = data['userId'] as String? ?? '';
        add(UserTypingUpdateReceived(chatId: chatId, userId: userId, isTyping: true));
      }),
    );

    _subscriptions.add(
      socketService.onUserStopTyping.listen((data) {
        final chatId = data['chatId'] as String? ?? '';
        final userId = data['userId'] as String? ?? '';
        add(UserTypingUpdateReceived(chatId: chatId, userId: userId, isTyping: false));
      }),
    );

    // 8. online & offline presence
    _subscriptions.add(
      socketService.onUserOnline.listen((data) {
        final userId = data['userId'] as String? ?? '';
        final lastSeenStr = data['lastSeen'] as String?;
        final lastSeen = lastSeenStr != null ? DateTime.tryParse(lastSeenStr) : null;
        add(UserPresenceUpdateReceived(userId: userId, isOnline: true, lastSeen: lastSeen));
      }),
    );

    _subscriptions.add(
      socketService.onUserOffline.listen((data) {
        final userId = data['userId'] as String? ?? '';
        final lastSeenStr = data['lastSeen'] as String?;
        final lastSeen = lastSeenStr != null ? DateTime.tryParse(lastSeenStr) : null;
        add(UserPresenceUpdateReceived(userId: userId, isOnline: false, lastSeen: lastSeen));
      }),
    );

    // 9. chat_cleared
    _subscriptions.add(
      socketService.onChatCleared.listen((data) {
        final chatId = data['chatId'] as String? ?? '';
        add(ChatClearedReceived(chatId: chatId));
      }),
    );

    // 10. chat_request_accepted & declined
    _subscriptions.add(
      socketService.onChatRequestAccepted.listen((data) {
        final chatId = data['chatId'] as String? ?? '';
        add(ChatRequestAcceptedReceived(chatId: chatId));
      }),
    );

    _subscriptions.add(
      socketService.onChatRequestDeclined.listen((data) {
        final chatId = data['chatId'] as String? ?? '';
        add(ChatRequestDeclinedReceived(chatId: chatId));
      }),
    );
  }

  void _onDisconnectSocketRequested(DisconnectSocketRequested event, Emitter<ChatState> emit) {
    _cancelSubscriptions();
    socketService.disconnect();
  }

  void _onJoinChatRequested(JoinChatRequested event, Emitter<ChatState> emit) {
    socketService.joinChat(event.chatId);
    socketService.markRead(chatId: event.chatId);
  }

  void _onLeaveChatRequested(LeaveChatRequested event, Emitter<ChatState> emit) {
    socketService.leaveChat(event.chatId);
  }

  Future<void> _onGetOrCreateChatRequested(GetOrCreateChatRequested event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    try {
      final chat = await chatRepository.getOrCreateChat(userId: event.userId);
      emit(ChatSessionCreated(chat: chat));
    } catch (e) {
      emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetInboxChatsRequested(GetInboxChatsRequested event, Emitter<ChatState> emit) async {
    if (_cachedInboxChats.isEmpty) {
      emit(const ChatLoading());
    }
    try {
      final chats = await chatRepository.getInboxChats();
      _cachedInboxChats = chats;
      emit(InboxChatsLoaded(chats: chats));
    } catch (e) {
      if (_cachedInboxChats.isNotEmpty) {
        emit(InboxChatsLoaded(chats: _cachedInboxChats));
      } else {
        emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onGetChatMessagesRequested(GetChatMessagesRequested event, Emitter<ChatState> emit) async {
    final currentState = state;
    List<Message> currentMessages = [];
    Map<String, bool> typingUsers = {};
    Map<String, bool> onlineUsers = {};
    Map<String, DateTime?> lastSeenUsers = {};
    Chat? currentChat = event.chat;

    if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId) {
      currentChat ??= currentState.chat;
      typingUsers = currentState.typingUsers;
      onlineUsers = currentState.onlineUsers;
      lastSeenUsers = currentState.lastSeenUsers;
      if (event.isLoadMore) {
        currentMessages = currentState.messages;
      }
    }

    if (!event.isLoadMore) {
      emit(const ChatLoading());
    } else if (currentState is ChatMessagesLoaded) {
      emit(currentState.copyWith(isLoadingMore: true));
    }

    try {
      final response = await chatRepository.getChatMessages(
        chatId: event.chatId,
        before: event.before,
        limit: 50,
      );

      // Server returns oldest first. For reversed list, newest first:
      final fetchedReversed = response.messages.reversed.toList();

      List<Message> combinedMessages;
      if (event.isLoadMore) {
        // Append older messages to end of the list
        combinedMessages = [...currentMessages, ...fetchedReversed];
      } else {
        combinedMessages = fetchedReversed;
      }

      // Deduplicate messages by id
      final seenIds = <String>{};
      final uniqueMessages = <Message>[];
      for (final m in combinedMessages) {
        if (m.id.isNotEmpty && !seenIds.contains(m.id)) {
          seenIds.add(m.id);
          uniqueMessages.add(m);
        }
      }

      emit(
        ChatMessagesLoaded(
          messages: uniqueMessages,
          chatId: event.chatId,
          hasReachedMax: !response.hasMore,
          nextCursor: response.nextCursor,
          isLoadingMore: false,
          typingUsers: typingUsers,
          chat: currentChat,
          onlineUsers: onlineUsers,
          lastSeenUsers: lastSeenUsers,
        ),
      );
    } catch (e) {
      emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onSendTextMessageRequested(SendTextMessageRequested event, Emitter<ChatState> emit) {
    socketService.sendMessage(
      chatId: event.chatId,
      text: event.text,
      replyToId: event.replyToId,
      sharedPostId: event.sharedPostId,
      sharedStoryId: event.sharedStoryId,
      onAck: (ack) {
        if (ack['success'] == true) {
          try {
            final msgJson = ack['data']['message'] as Map<String, dynamic>;
            final message = MessageModel.fromJson(msgJson);
            add(MessageReceived(message: message, chatId: event.chatId));
          } catch (e) {
            debugPrint('Error parsing sent message ack: $e');
          }
        }
      },
    );
  }

  Future<void> _onSendMediaMessageRequested(SendMediaMessageRequested event, Emitter<ChatState> emit) async {
    try {
      final message = await chatRepository.sendMediaMessage(
        chatId: event.chatId,
        media: event.media,
        text: event.text,
        replyToId: event.replyToId,
        messageType: event.messageType,
      );
      add(MessageReceived(message: message, chatId: event.chatId));
    } catch (e) {
      emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAcceptMessageRequestRequested(AcceptMessageRequestRequested event, Emitter<ChatState> emit) async {
    try {
      final chat = await chatRepository.acceptMessageRequest(chatId: event.chatId);
      emit(ChatSessionCreated(chat: chat));
      add(const GetInboxChatsRequested());
    } catch (e) {
      emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeclineMessageRequestRequested(DeclineMessageRequestRequested event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.declineMessageRequest(chatId: event.chatId);
      emit(const ChatActionSuccess(message: 'Message request declined'));
      add(const GetInboxChatsRequested());
    } catch (e) {
      emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onMarkMessagesReadRequested(MarkMessagesReadRequested event, Emitter<ChatState> emit) {
    socketService.markRead(chatId: event.chatId);
  }

  void _onReactMessageRequested(ReactMessageRequested event, Emitter<ChatState> emit) {
    socketService.reactMessage(messageId: event.messageId, emoji: event.emoji);

    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      final updatedMessages = currentState.messages.map((m) {
        if (m.id == event.messageId) {
          final existingReactions = List<MessageReaction>.from(m.reactions);
          final userReactionIndex = existingReactions.indexWhere((r) => r.userId == event.userId);

          if (userReactionIndex != -1) {
            final existingReaction = existingReactions[userReactionIndex];
            if (existingReaction.emoji == event.emoji) {
              existingReactions.removeAt(userReactionIndex);
            } else {
              existingReactions[userReactionIndex] = MessageReaction(
                userId: event.userId,
                username: event.username,
                fullName: event.fullName,
                emoji: event.emoji,
              );
            }
          } else {
            existingReactions.add(
              MessageReaction(
                userId: event.userId,
                username: event.username,
                fullName: event.fullName,
                emoji: event.emoji,
              ),
            );
          }

          return m.copyWith(reactions: existingReactions);
        }
        return m;
      }).toList();

      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  void _onDeleteMessageRequested(DeleteMessageRequested event, Emitter<ChatState> emit) {
    socketService.deleteMessage(messageId: event.messageId);

    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      final updatedMessages = currentState.messages.map((m) {
        if (m.id == event.messageId) {
          return m.copyWith(
            text: 'This message was deleted',
            isDeleted: true,
            reactions: const [],
          );
        }
        return m;
      }).toList();

      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  Future<void> _onClearChatRequested(ClearChatRequested event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.clearChatMessages(chatId: event.chatId);
      final currentState = state;
      if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId) {
        emit(currentState.copyWith(messages: []));
      }
      add(const GetInboxChatsRequested());
    } catch (e) {
      emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSearchChatMessagesRequested(SearchChatMessagesRequested event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      emit(currentState.copyWith(isSearching: true, searchQuery: event.query));
      try {
        final results = await chatRepository.searchChatMessages(chatId: event.chatId, query: event.query);
        emit(currentState.copyWith(searchResults: results, isSearching: true, searchQuery: event.query));
      } catch (e) {
        emit(currentState.copyWith(isSearching: false));
      }
    }
  }

  void _onClearSearchRequested(ClearSearchRequested event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      emit(currentState.copyWith(isSearching: false, searchResults: null, searchQuery: null));
    }
  }

  void _onTypingStatusChanged(TypingStatusChanged event, Emitter<ChatState> emit) {
    if (event.isTyping) {
      socketService.typing(chatId: event.chatId);
    } else {
      socketService.stopTyping(chatId: event.chatId);
    }
  }

  void _onCheckUserPresenceRequested(CheckUserPresenceRequested event, Emitter<ChatState> emit) {
    socketService.getUserPresence(
      targetUserId: event.targetUserId,
      onAck: (ack) {
        if (ack['success'] == true && ack['data'] != null) {
          final data = ack['data'] as Map<String, dynamic>;
          final isOnline = data['isOnline'] as bool? ?? false;
          final lastSeenStr = data['lastSeen'] as String?;
          final lastSeen = lastSeenStr != null ? DateTime.tryParse(lastSeenStr) : null;
          add(UserPresenceUpdateReceived(userId: event.targetUserId, isOnline: isOnline, lastSeen: lastSeen));
        }
      },
    );
  }

  // Socket updates handlers
  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId) {
      // Deduplicate by _id
      if (currentState.messages.any((m) => m.id == event.message.id)) return;

      // Newest message at index 0 for reversed list
      final updatedMessages = [event.message, ...currentState.messages];
      emit(currentState.copyWith(messages: updatedMessages));

      // Mark as read immediately since the chat is open
      socketService.markRead(chatId: event.chatId);
    }

    // Update inbox preview if cached
    _updateInboxWithNewMessage(event.chatId, event.message);
  }

  void _onNewSentMessageReceived(NewSentMessageReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId) {
      if (currentState.messages.any((m) => m.id == event.message.id)) return;
      final updatedMessages = [event.message, ...currentState.messages];
      emit(currentState.copyWith(messages: updatedMessages));
    }
    _updateInboxWithNewMessage(event.chatId, event.message);
  }

  void _onMessagesDeliveredReceived(MessagesDeliveredReceived event, Emitter<ChatState> emit) {
    final deliveredIds = event.deliveredMessages.map((m) => m['messageId'] as String? ?? '').toSet();
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      final updatedMessages = currentState.messages.map((m) {
        if (deliveredIds.contains(m.id) && m.status == 'sent') {
          return m.copyWith(status: 'delivered');
        }
        return m;
      }).toList();

      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  void _onMessageReadUpdateReceived(MessageReadUpdateReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId) {
      final updatedMessages = currentState.messages.map((m) {
        if (m.sender.id != event.readBy) {
          return m.copyWith(status: 'read', isRead: true);
        }
        return m;
      }).toList();

      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  void _onMessageReactedUpdateReceived(MessageReactedUpdateReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      final updatedMessages = currentState.messages.map((m) {
        if (m.id == event.messageId) {
          return m.copyWith(reactions: event.reactions);
        }
        return m;
      }).toList();

      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  void _onMessageDeletedUpdateReceived(MessageDeletedUpdateReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      final updatedMessages = currentState.messages.map((m) {
        if (m.id == event.messageId) {
          return m.copyWith(
            text: 'This message was deleted',
            isDeleted: true,
            reactions: const [],
          );
        }
        return m;
      }).toList();

      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  void _onUserTypingUpdateReceived(UserTypingUpdateReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId) {
      final updatedTypingUsers = Map<String, bool>.from(currentState.typingUsers);
      if (event.isTyping) {
        updatedTypingUsers[event.userId] = true;
      } else {
        updatedTypingUsers.remove(event.userId);
      }
      emit(currentState.copyWith(typingUsers: updatedTypingUsers));
    } else if (currentState is InboxChatsLoaded) {
      final updatedTypingChats = Map<String, bool>.from(currentState.typingChats);
      if (event.isTyping) {
        updatedTypingChats[event.chatId] = true;
      } else {
        updatedTypingChats.remove(event.chatId);
      }
      emit(currentState.copyWith(typingChats: updatedTypingChats));
    }
  }

  void _onUserPresenceUpdateReceived(UserPresenceUpdateReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      final updatedOnline = Map<String, bool>.from(currentState.onlineUsers);
      final updatedLastSeen = Map<String, DateTime?>.from(currentState.lastSeenUsers);

      updatedOnline[event.userId] = event.isOnline;
      if (event.lastSeen != null) {
        updatedLastSeen[event.userId] = event.lastSeen;
      }

      // Also update participant in chat if matched
      Chat? updatedChat = currentState.chat;
      if (updatedChat != null) {
        final updatedParticipants = updatedChat.participants.map((p) {
          if (p.id == event.userId) {
            return p.copyWith(
              isOnline: event.isOnline,
              lastSeen: event.lastSeen ?? p.lastSeen,
            );
          }
          return p;
        }).toList();
        updatedChat = updatedChat.copyWith(participants: updatedParticipants);
      }

      emit(
        currentState.copyWith(
          onlineUsers: updatedOnline,
          lastSeenUsers: updatedLastSeen,
          chat: updatedChat,
        ),
      );
    } else if (currentState is InboxChatsLoaded) {
      final updatedChats = currentState.chats.map((c) {
        final updatedParticipants = c.participants.map((p) {
          if (p.id == event.userId) {
            return p.copyWith(
              isOnline: event.isOnline,
              lastSeen: event.lastSeen ?? p.lastSeen,
            );
          }
          return p;
        }).toList();
        return c.copyWith(participants: updatedParticipants);
      }).toList();

      emit(currentState.copyWith(chats: updatedChats));
    }
  }

  void _onChatClearedReceived(ChatClearedReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId) {
      emit(currentState.copyWith(messages: []));
    }
    add(const GetInboxChatsRequested());
  }

  void _onChatRequestAcceptedReceived(ChatRequestAcceptedReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId && currentState.chat != null) {
      emit(currentState.copyWith(chat: currentState.chat!.copyWith(status: 'accepted')));
    }
    add(const GetInboxChatsRequested());
  }

  void _onChatRequestDeclinedReceived(ChatRequestDeclinedReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId && currentState.chat != null) {
      emit(currentState.copyWith(chat: currentState.chat!.copyWith(status: 'declined')));
    }
    add(const GetInboxChatsRequested());
  }

  void _onInboxChatsRefreshed(InboxChatsRefreshed event, Emitter<ChatState> emit) {
    if (state is InboxChatsLoaded) {
      emit((state as InboxChatsLoaded).copyWith(chats: event.chats));
    }
  }

  void _updateInboxWithNewMessage(String chatId, Message message) {
    if (_cachedInboxChats.isEmpty) return;
    final index = _cachedInboxChats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final existingChat = _cachedInboxChats[index];
      final updatedChat = existingChat.copyWith(
        lastMessage: message,
        lastMessageTime: message.createdAt,
      );
      _cachedInboxChats[index] = updatedChat;
      // Bring to top
      _cachedInboxChats.removeAt(index);
      _cachedInboxChats.insert(0, updatedChat);

      add(InboxChatsRefreshed(chats: List.from(_cachedInboxChats)));
    }
  }

  void _cancelSubscriptions() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
