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

  ChatBloc({required this.chatRepository, required this.socketService}) : super(const ChatInitial()) {
    on<ConnectSocketRequested>(_onConnectSocketRequested);
    on<DisconnectSocketRequested>(_onDisconnectSocketRequested);
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
    on<TypingStatusChanged>(_onTypingStatusChanged);

    // Socket updates
    on<MessageReceived>(_onMessageReceived);
    on<MessageReadUpdateReceived>(_onMessageReadUpdateReceived);
    on<MessageReactedUpdateReceived>(_onMessageReactedUpdateReceived);
    on<MessageDeletedUpdateReceived>(_onMessageDeletedUpdateReceived);
    on<UserTypingUpdateReceived>(_onUserTypingUpdateReceived);
    on<UserPresenceUpdateReceived>(_onUserPresenceUpdateReceived);
  }

  void _onConnectSocketRequested(ConnectSocketRequested event, Emitter<ChatState> emit) {
    _cancelSubscriptions();
    socketService.connect(event.token);

    _subscriptions.add(
      socketService.onMessageReceived.listen((data) {
        try {
          final msgJson = data['message'] as Map<String, dynamic>;
          final message = MessageModel.fromJson(msgJson);
          add(MessageReceived(message: message));
        } catch (e) {
          debugPrint('Error parsing received message: $e');
        }
      }),
    );

    _subscriptions.add(
      socketService.onMessagesRead.listen((data) {
        final chatId = data['chatId'] as String? ?? '';
        final readBy = data['readBy'] as String? ?? '';
        add(MessageReadUpdateReceived(chatId: chatId, readBy: readBy));
      }),
    );

    _subscriptions.add(
      socketService.onMessageReacted.listen((data) {
        final messageId = data['messageId'] as String? ?? '';
        final reactionsList = data['reactions'] as List? ?? [];
        final reactions = reactionsList.map((r) => MessageReactionModel.fromJson(r as Map<String, dynamic>)).toList();
        add(MessageReactedUpdateReceived(messageId: messageId, reactions: reactions));
      }),
    );

    _subscriptions.add(
      socketService.onMessageDeleted.listen((data) {
        final messageId = data['messageId'] as String? ?? '';
        add(MessageDeletedUpdateReceived(messageId: messageId));
      }),
    );

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

    _subscriptions.add(
      socketService.onUserOnline.listen((data) {
        final userId = data['userId'] as String? ?? '';
        add(UserPresenceUpdateReceived(userId: userId, isOnline: true));
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
  }

  void _onDisconnectSocketRequested(DisconnectSocketRequested event, Emitter<ChatState> emit) {
    _cancelSubscriptions();
    socketService.disconnect();
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
    emit(const ChatLoading());
    try {
      final chats = await chatRepository.getInboxChats();
      emit(InboxChatsLoaded(chats: chats));
    } catch (e) {
      emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetChatMessagesRequested(GetChatMessagesRequested event, Emitter<ChatState> emit) async {
    final currentState = state;
    List<Message> currentMessages = [];
    Map<String, bool> typingUsers = {};
    Chat? currentChat;

    if (event.chat != null) {
      currentChat = event.chat;
    } else if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId) {
      currentChat = currentState.chat;
    }

    if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId && event.page > 1) {
      currentMessages = currentState.messages;
      typingUsers = currentState.typingUsers;
    }

    if (event.page == 1) {
      emit(const ChatLoading());
    }

    try {
      if (event.page == 1) {
        if (currentChat != null) {
          final messages = await chatRepository.getChatMessages(chatId: event.chatId, page: 1);
          emit(
            ChatMessagesLoaded(
              messages: messages.reversed.toList(),
              chatId: event.chatId,
              hasReachedMax: messages.isEmpty,
              currentPage: 1,
              typingUsers: typingUsers,
              chat: currentChat,
            ),
          );
        } else {
          final results = await Future.wait([
            chatRepository.getInboxChats(),
            chatRepository.getChatMessages(chatId: event.chatId, page: 1),
          ]);
          final chats = results[0] as List<Chat>;
          final messages = results[1] as List<Message>;

          final chat = chats.cast<Chat>().firstWhere(
            (c) => c.id == event.chatId,
            orElse: () => Chat(
              id: event.chatId,
              participants: const [],
              status: 'accepted',
              unreadCount: const {},
              lastMessageTime: DateTime.now(),
            ),
          );

          emit(
            ChatMessagesLoaded(
              messages: messages.reversed.toList(),
              chatId: event.chatId,
              hasReachedMax: messages.isEmpty,
              currentPage: 1,
              typingUsers: typingUsers,
              chat: chat,
            ),
          );
        }
      } else {
        final messages = await chatRepository.getChatMessages(chatId: event.chatId, page: event.page);
        emit(
          ChatMessagesLoaded(
            messages: [...currentMessages, ...messages.reversed],
            chatId: event.chatId,
            hasReachedMax: messages.isEmpty,
            currentPage: event.page,
            typingUsers: typingUsers,
            chat: currentChat,
          ),
        );
      }
    } catch (e) {
      emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onSendTextMessageRequested(SendTextMessageRequested event, Emitter<ChatState> emit) {
    socketService.sendMessage(
      chatId: event.chatId,
      text: event.text,
      sharedPostId: event.sharedPostId,
      sharedStoryId: event.sharedStoryId,
      onAck: (ack) {
        if (ack['success'] == true) {
          try {
            final msgJson = ack['data']['message'] as Map<String, dynamic>;
            final message = MessageModel.fromJson(msgJson);
            add(MessageReceived(message: message));
          } catch (e) {
            debugPrint('Error parsing sent message ack: $e');
          }
        }
      },
    );
  }

  Future<void> _onSendMediaMessageRequested(SendMediaMessageRequested event, Emitter<ChatState> emit) async {
    try {
      final message = await chatRepository.sendMediaMessage(chatId: event.chatId, media: event.media, text: event.text);
      add(MessageReceived(message: message));
    } catch (e) {
      emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAcceptMessageRequestRequested(AcceptMessageRequestRequested event, Emitter<ChatState> emit) async {
    try {
      final chat = await chatRepository.acceptMessageRequest(chatId: event.chatId);
      emit(ChatSessionCreated(chat: chat));
    } catch (e) {
      emit(ChatFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeclineMessageRequestRequested(DeclineMessageRequestRequested event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.declineMessageRequest(chatId: event.chatId);
      emit(const ChatActionSuccess(message: 'Message request declined'));
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

          return Message(
            id: m.id,
            chatId: m.chatId,
            sender: m.sender,
            messageType: m.messageType,
            text: m.text,
            media: m.media,
            sharedPostId: m.sharedPostId,
            sharedStoryId: m.sharedStoryId,
            reactions: existingReactions,
            isRead: m.isRead,
            isDeleted: m.isDeleted,
            createdAt: m.createdAt,
          );
        }
        return m;
      }).toList();

      emit(
        ChatMessagesLoaded(
          messages: updatedMessages,
          chatId: currentState.chatId,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          typingUsers: currentState.typingUsers,
          chat: currentState.chat,
        ),
      );
    }
  }

  void _onDeleteMessageRequested(DeleteMessageRequested event, Emitter<ChatState> emit) {
    socketService.deleteMessage(messageId: event.messageId);

    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      final updatedMessages = currentState.messages.map((m) {
        if (m.id == event.messageId) {
          return Message(
            id: m.id,
            chatId: m.chatId,
            sender: m.sender,
            messageType: m.messageType,
            text: 'This message was deleted',
            media: null,
            sharedPostId: null,
            sharedStoryId: null,
            reactions: const [],
            isRead: m.isRead,
            isDeleted: true,
            createdAt: m.createdAt,
          );
        }
        return m;
      }).toList();

      emit(
        ChatMessagesLoaded(
          messages: updatedMessages,
          chatId: currentState.chatId,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          typingUsers: currentState.typingUsers,
          chat: currentState.chat,
        ),
      );
    }
  }

  void _onTypingStatusChanged(TypingStatusChanged event, Emitter<ChatState> emit) {
    if (event.isTyping) {
      socketService.typing(chatId: event.chatId);
    } else {
      socketService.stopTyping(chatId: event.chatId);
    }
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded && currentState.chatId == event.message.chatId) {
      // Avoid adding duplicate messages
      if (currentState.messages.any((m) => m.id == event.message.id)) return;

      final updatedMessages = [event.message, ...currentState.messages];
      emit(
        ChatMessagesLoaded(
          messages: updatedMessages,
          chatId: currentState.chatId,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          typingUsers: currentState.typingUsers,
          chat: currentState.chat,
        ),
      );
    }
  }

  void _onMessageReadUpdateReceived(MessageReadUpdateReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded && currentState.chatId == event.chatId) {
      final updatedMessages = currentState.messages.map((m) {
        if (m.sender.id != event.readBy) {
          return Message(
            id: m.id,
            chatId: m.chatId,
            sender: m.sender,
            messageType: m.messageType,
            text: m.text,
            media: m.media,
            sharedPostId: m.sharedPostId,
            sharedStoryId: m.sharedStoryId,
            reactions: m.reactions,
            isRead: true,
            isDeleted: m.isDeleted,
            createdAt: m.createdAt,
          );
        }
        return m;
      }).toList();

      emit(
        ChatMessagesLoaded(
          messages: updatedMessages,
          chatId: currentState.chatId,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          typingUsers: currentState.typingUsers,
          chat: currentState.chat,
        ),
      );
    }
  }

  void _onMessageReactedUpdateReceived(MessageReactedUpdateReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      final updatedMessages = currentState.messages.map((m) {
        if (m.id == event.messageId) {
          return Message(
            id: m.id,
            chatId: m.chatId,
            sender: m.sender,
            messageType: m.messageType,
            text: m.text,
            media: m.media,
            sharedPostId: m.sharedPostId,
            sharedStoryId: m.sharedStoryId,
            reactions: event.reactions,
            isRead: m.isRead,
            isDeleted: m.isDeleted,
            createdAt: m.createdAt,
          );
        }
        return m;
      }).toList();

      emit(
        ChatMessagesLoaded(
          messages: updatedMessages,
          chatId: currentState.chatId,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          typingUsers: currentState.typingUsers,
          chat: currentState.chat,
        ),
      );
    }
  }

  void _onMessageDeletedUpdateReceived(MessageDeletedUpdateReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      final updatedMessages = currentState.messages.map((m) {
        if (m.id == event.messageId) {
          return Message(
            id: m.id,
            chatId: m.chatId,
            sender: m.sender,
            messageType: m.messageType,
            text: 'This message was deleted',
            media: null,
            sharedPostId: null,
            sharedStoryId: null,
            reactions: const [],
            isRead: m.isRead,
            isDeleted: true,
            createdAt: m.createdAt,
          );
        }
        return m;
      }).toList();

      emit(
        ChatMessagesLoaded(
          messages: updatedMessages,
          chatId: currentState.chatId,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          typingUsers: currentState.typingUsers,
          chat: currentState.chat,
        ),
      );
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

      emit(
        ChatMessagesLoaded(
          messages: currentState.messages,
          chatId: currentState.chatId,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          typingUsers: updatedTypingUsers,
          chat: currentState.chat,
        ),
      );
    }
  }

  void _onUserPresenceUpdateReceived(UserPresenceUpdateReceived event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      // Update participant online status if they are in the active chat
      final updatedMessages = currentState.messages.map((m) {
        if (m.sender.id == event.userId) {
          final updatedSender = ChatParticipant(
            id: m.sender.id,
            username: m.sender.username,
            fullName: m.sender.fullName,
            profilePicture: m.sender.profilePicture,
            isOnline: event.isOnline,
            lastSeen: event.lastSeen ?? m.sender.lastSeen,
          );
          return Message(
            id: m.id,
            chatId: m.chatId,
            sender: updatedSender,
            messageType: m.messageType,
            text: m.text,
            media: m.media,
            sharedPostId: m.sharedPostId,
            sharedStoryId: m.sharedStoryId,
            reactions: m.reactions,
            isRead: m.isRead,
            isDeleted: m.isDeleted,
            createdAt: m.createdAt,
          );
        }
        return m;
      }).toList();

      emit(
        ChatMessagesLoaded(
          messages: updatedMessages,
          chatId: currentState.chatId,
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
          typingUsers: currentState.typingUsers,
          chat: currentState.chat,
        ),
      );
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
