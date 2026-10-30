import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_event.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_state.dart';
import 'package:vagabond/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:vagabond/features/chat/presentation/widgets/chat_date_divider.dart';
import 'package:vagabond/features/chat/presentation/widgets/chat_input_area.dart';
import 'package:vagabond/features/chat/presentation/widgets/chat_pending_request_banner.dart';
import 'package:vagabond/features/chat/presentation/widgets/message_tile.dart';
import 'package:vagabond/features/chat/presentation/widgets/reaction_picker_bar.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/features/chat/presentation/widgets/whatsapp_theme.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String? userId; // Used if chat session is not created yet
  final Chat? chat;

  const ChatScreen({super.key, this.chatId, this.userId, this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  Timer? _typingTimer;
  bool _isTyping = false;
  String? _activeChatId;
  Chat? _chat;
  ReplyMessage? _replyingTo;
  bool _isSearchMode = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _activeChatId = widget.chatId;
    _chat = widget.chat;
    _scrollController.addListener(_onScroll);
    _initializeChat();
  }

  void _initializeChat() {
    if (_activeChatId != null) {
      context.read<ChatBloc>().add(JoinChatRequested(chatId: _activeChatId!));
      context.read<ChatBloc>().add(GetChatMessagesRequested(chatId: _activeChatId!, chat: _chat));

      // Query online presence for the other participant
      final currentUser = context.read<AuthBloc>().currentUser;
      final otherParticipant = _chat?.participants.cast<ChatParticipant?>().firstWhere(
            (p) => p?.id != currentUser?.id,
            orElse: () => null,
          );
      if (otherParticipant != null) {
        context.read<ChatBloc>().add(CheckUserPresenceRequested(targetUserId: otherParticipant.id));
      }
    } else if (widget.userId != null) {
      context.read<ChatBloc>().add(GetOrCreateChatRequested(userId: widget.userId!));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ChatBloc>().state;
      if (state is ChatMessagesLoaded && !state.hasReachedMax && !state.isLoadingMore && _activeChatId != null) {
        context.read<ChatBloc>().add(
              GetChatMessagesRequested(
                chatId: _activeChatId!,
                before: state.nextCursor,
                isLoadMore: true,
                chat: _chat,
              ),
            );
      }
    }
  }

  @override
  void dispose() {
    if (_activeChatId != null) {
      context.read<ChatBloc>().add(LeaveChatRequested(chatId: _activeChatId!));
    }
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (_activeChatId == null) return;

    if (text.isNotEmpty) {
      if (!_isTyping) {
        _isTyping = true;
        context.read<ChatBloc>().add(TypingStatusChanged(chatId: _activeChatId!, isTyping: true));
      }

      // Debounce: stop typing after 3s of inactivity
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (_isTyping) {
          _isTyping = false;
          context.read<ChatBloc>().add(TypingStatusChanged(chatId: _activeChatId!, isTyping: false));
        }
      });
    } else {
      if (_isTyping) {
        _isTyping = false;
        context.read<ChatBloc>().add(TypingStatusChanged(chatId: _activeChatId!, isTyping: false));
      }
      _typingTimer?.cancel();
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _activeChatId == null) return;

    context.read<ChatBloc>().add(
          SendTextMessageRequested(
            chatId: _activeChatId!,
            text: text,
            replyToId: _replyingTo?.id,
          ),
        );

    _messageController.clear();
    setState(() => _replyingTo = null);

    if (_isTyping) {
      _isTyping = false;
      context.read<ChatBloc>().add(TypingStatusChanged(chatId: _activeChatId!, isTyping: false));
    }
    _typingTimer?.cancel();
  }

  Future<void> _pickGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null && _activeChatId != null) {
      _sendMedia(File(file.path), 'image');
    }
  }

  Future<void> _pickCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file != null && _activeChatId != null) {
      _sendMedia(File(file.path), 'image');
    }
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null && _activeChatId != null) {
      _sendMedia(File(file.path), 'video');
    }
  }

  void _sendMedia(File file, String type) {
    context.read<ChatBloc>().add(
          SendMediaMessageRequested(
            chatId: _activeChatId!,
            media: file,
            replyToId: _replyingTo?.id,
            messageType: type,
          ),
        );
    setState(() => _replyingTo = null);
  }

  void _showReactions(BuildContext context, Message message) {
    final currentUser = context.read<AuthBloc>().currentUser;
    final isMe = message.sender.id == currentUser?.id;

    ReactionPickerBar.show(
      context: context,
      message: message,
      isMe: isMe,
      onReact: (emoji) {
        if (currentUser != null) {
          context.read<ChatBloc>().add(
                ReactMessageRequested(
                  messageId: message.id,
                  emoji: emoji,
                  userId: currentUser.id,
                  username: currentUser.username,
                  fullName: currentUser.fullName,
                ),
              );
        }
      },
      onReply: () {
        setState(() {
          _replyingTo = ReplyMessage(
            id: message.id,
            text: message.text,
            messageType: message.messageType,
            senderUsername: message.sender.username,
            senderFullName: message.sender.fullName,
          );
        });
      },
      onDelete: () {
        context.read<ChatBloc>().add(DeleteMessageRequested(messageId: message.id));
      },
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WhatsAppTheme.cardBackground,
        title: const Text('Clear this chat?', style: TextStyle(color: WhatsAppTheme.textPrimary)),
        content: const Text(
          'Messages will be cleared for both participants in this conversation.',
          style: TextStyle(color: WhatsAppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: WhatsAppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_activeChatId != null) {
                context.read<ChatBloc>().add(ClearChatRequested(chatId: _activeChatId!));
              }
            },
            child: const Text('Clear Chat', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthBloc>().currentUser;

    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatSessionCreated) {
          setState(() {
            _chat = state.chat;
            _activeChatId = state.chat.id;
          });
          context.read<ChatBloc>().add(JoinChatRequested(chatId: state.chat.id));
          context.read<ChatBloc>().add(GetChatMessagesRequested(chatId: state.chat.id, chat: state.chat));
        } else if (state is ChatMessagesLoaded && state.chat != null) {
          setState(() {
            _chat = state.chat;
          });
        } else if (state is ChatFailure) {
          CustomSnackBar.showError(context, state.error);
        } else if (state is ChatActionSuccess) {
          CustomSnackBar.showSuccess(context, state.message);
        }
      },
      builder: (context, state) {
        List<Message> messages = [];
        Map<String, bool> typingUsers = {};
        Map<String, bool> onlineUsers = {};
        Map<String, DateTime?> lastSeenUsers = {};

        if (state is ChatMessagesLoaded) {
          messages = state.messages;
          typingUsers = state.typingUsers;
          onlineUsers = state.onlineUsers;
          lastSeenUsers = state.lastSeenUsers;
        }

        final otherParticipant = _chat?.participants.cast<ChatParticipant?>().firstWhere(
              (p) => p?.id != currentUser?.id,
              orElse: () => _chat?.participants.isNotEmpty == true ? _chat!.participants.first : null,
            );

        final otherUserId = otherParticipant?.id ?? '';
        final isOtherOnline = onlineUsers[otherUserId] ?? otherParticipant?.isOnline ?? false;
        final otherLastSeen = lastSeenUsers[otherUserId] ?? otherParticipant?.lastSeen;
        final isOtherTyping = typingUsers[otherUserId] ?? false;

        final isPending = _chat?.status == 'pending';
        final isRequester = _chat?.requestedBy == currentUser?.id;

        // Filter messages if search mode active
        final displayedMessages = _isSearchMode && _searchQuery.isNotEmpty
            ? messages.where((m) => m.text.toLowerCase().contains(_searchQuery.toLowerCase())).toList()
            : messages;

        return Scaffold(
          backgroundColor: WhatsAppTheme.darkBackground,
          appBar: ChatAppBar(
            chat: _chat,
            currentUser: currentUser,
            isTyping: isOtherTyping,
            isOnline: isOtherOnline,
            lastSeen: otherLastSeen,
            isSearchMode: _isSearchMode,
            searchController: _searchController,
            onBackPressed: () => Navigator.pop(context),
            onToggleSearch: () {
              setState(() {
                _isSearchMode = !_isSearchMode;
                if (!_isSearchMode) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
            },
            onClearChat: _confirmClearChat,
          ),
          body: (state is ChatLoading && _chat == null)
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(WhatsAppTheme.primaryGreen),
                  ),
                )
              : Column(
                  children: [
                    // Messages List
                    Expanded(
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        behavior: HitTestBehavior.translucent,
                        child: displayedMessages.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: WhatsAppTheme.datePillBackground.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _isSearchMode ? 'No matching messages' : 'No messages here yet.',
                                  style: const TextStyle(color: WhatsAppTheme.datePillText, fontSize: 13),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              itemCount: displayedMessages.length + (isOtherTyping ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Typing bubble at index 0 (bottom) if other user is typing
                                if (isOtherTyping && index == 0) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      margin: const EdgeInsets.only(bottom: 6),
                                      decoration: BoxDecoration(
                                        color: WhatsAppTheme.otherMessageBubble,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${otherParticipant?.fullName ?? "Someone"} is typing',
                                            style: const TextStyle(
                                              color: WhatsAppTheme.primaryGreen,
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(WhatsAppTheme.primaryGreen),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final msgIndex = isOtherTyping ? index - 1 : index;
                                final message = displayedMessages[msgIndex];

                                // Check if a Date Divider should be shown above this message
                                bool showDateDivider = false;
                                if (msgIndex == displayedMessages.length - 1) {
                                  // Oldest message always has a date header
                                  showDateDivider = true;
                                } else {
                                  final previousMessage = displayedMessages[msgIndex + 1];
                                  showDateDivider = !ChatDateDivider.isSameDay(
                                    message.createdAt,
                                    previousMessage.createdAt,
                                  );
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (showDateDivider) ChatDateDivider(date: message.createdAt),
                                    MessageTile(
                                      message: message,
                                      currentUser: currentUser,
                                      onLongPress: () => _showReactions(context, message),
                                      onReply: () {
                                        setState(() {
                                          _replyingTo = ReplyMessage(
                                            id: message.id,
                                            text: message.text,
                                            messageType: message.messageType,
                                            senderUsername: message.sender.username,
                                            senderFullName: message.sender.fullName,
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                      ),
                    ),

                    // Bottom Area (Message Request Banner or WhatsApp Input)
                    if (isPending)
                      ChatPendingRequestBanner(
                        isRequester: isRequester,
                        onAccept: () {
                          context.read<ChatBloc>().add(AcceptMessageRequestRequested(chatId: _activeChatId!));
                        },
                        onDecline: () {
                          context.read<ChatBloc>().add(DeclineMessageRequestRequested(chatId: _activeChatId!));
                          Navigator.pop(context);
                        },
                      )
                    else
                      ChatInputArea(
                        controller: _messageController,
                        onTextChanged: _onTextChanged,
                        onPickGallery: _pickGallery,
                        onPickCamera: _pickCamera,
                        onPickVideo: _pickVideo,
                        onSendMessage: _sendMessage,
                        replyingTo: _replyingTo,
                        onCancelReply: () => setState(() => _replyingTo = null),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
