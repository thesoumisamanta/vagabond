import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_event.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_state.dart';
import 'package:vagabond/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:vagabond/features/chat/presentation/widgets/chat_input_area.dart';
import 'package:vagabond/features/chat/presentation/widgets/chat_pending_request_banner.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/features/chat/presentation/widgets/message_tile.dart';

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
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  Timer? _typingTimer;
  bool _isTyping = false;
  String? _activeChatId;
  Chat? _chat;

  @override
  void initState() {
    super.initState();
    _activeChatId = widget.chatId;
    _chat = widget.chat;
    _initializeChat();
  }

  void _initializeChat() {
    if (_activeChatId != null) {
      context.read<ChatBloc>().add(GetChatMessagesRequested(chatId: _activeChatId!, chat: _chat));
      context.read<ChatBloc>().add(MarkMessagesReadRequested(chatId: _activeChatId!));
    } else if (widget.userId != null) {
      context.read<ChatBloc>().add(GetOrCreateChatRequested(userId: widget.userId!));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (_activeChatId == null) return;

    if (!_isTyping && text.isNotEmpty) {
      _isTyping = true;
      context.read<ChatBloc>().add(TypingStatusChanged(chatId: _activeChatId!, isTyping: true));
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        context.read<ChatBloc>().add(TypingStatusChanged(chatId: _activeChatId!, isTyping: false));
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _activeChatId == null) return;

    context.read<ChatBloc>().add(SendTextMessageRequested(chatId: _activeChatId!, text: text));
    _messageController.clear();
    if (_isTyping) {
      _isTyping = false;
      context.read<ChatBloc>().add(TypingStatusChanged(chatId: _activeChatId!, isTyping: false));
    }
  }

  Future<void> _pickAndSendMedia() async {
    if (_activeChatId == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text(AppStrings.chatGallery, style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickImage(source: ImageSource.gallery);
                if (file != null) _sendMedia(File(file.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.white),
              title: const Text(AppStrings.chatVideo, style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickVideo(source: ImageSource.gallery);
                if (file != null) _sendMedia(File(file.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMedia(File file) {
    context.read<ChatBloc>().add(SendMediaMessageRequested(chatId: _activeChatId!, media: file));
  }

  void _showReactions(BuildContext context, Message message) {
    final emojis = ['❤️', '👍', '🔥', '😂', '😮', '😢', '🙏'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: emojis.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      final currentUser = context.read<AuthBloc>().currentUser;
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
                    child: Text(emoji, style: const TextStyle(fontSize: 30)),
                  );
                }).toList(),
              ),
              if (message.sender.id == context.read<AuthBloc>().currentUser?.id && !message.isDeleted) ...[
                const Divider(color: Colors.white12, height: 24),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text(AppStrings.chatUnsendMessage, style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<ChatBloc>().add(DeleteMessageRequested(messageId: message.id));
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthBloc>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: ChatAppBar(chat: _chat, currentUser: currentUser, onBackPressed: () => Navigator.pop(context)),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatSessionCreated) {
            setState(() {
              _chat = state.chat;
              _activeChatId = state.chat.id;
            });
            context.read<ChatBloc>().add(GetChatMessagesRequested(chatId: state.chat.id, chat: state.chat));
          } else if (state is ChatMessagesLoaded && state.chat != null) {
            setState(() {
              _chat = state.chat;
            });
          } else if (state is ChatFailure) {
            CustomSnackBar.showError(context, state.error);
            // Revert optimistic accept if needed
            if (_chat != null && _chat!.status == 'accepted') {
              setState(() {
                _chat = Chat(
                  id: _chat!.id,
                  participants: _chat!.participants,
                  status: 'pending',
                  requestedBy: _chat!.requestedBy,
                  unreadCount: _chat!.unreadCount,
                  lastMessageTime: _chat!.lastMessageTime,
                  lastMessage: _chat!.lastMessage,
                );
              });
            }
          } else if (state is ChatActionSuccess) {
            CustomSnackBar.showSuccess(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ChatFailure && _chat == null) {
            return Center(
              child: Text(state.error, style: const TextStyle(color: Colors.white70)),
            );
          }

          if (_chat == null || state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
            );
          }

          List<Message> messages = [];
          Map<String, bool> typingUsers = {};

          if (state is ChatMessagesLoaded) {
            messages = state.messages;
            typingUsers = state.typingUsers;
          }

          final otherParticipant = _chat?.participants.cast<ChatParticipant>().firstWhere(
            (p) => p.id != currentUser?.id,
            orElse: () => _chat!.participants.first,
          );

          final isPending = _chat?.status == 'pending' && _chat?.requestedBy != currentUser?.id;

          return Column(
            children: [
              // Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length + (typingUsers.isNotEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (typingUsers.isNotEmpty && index == 0) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${otherParticipant?.fullName ?? AppStrings.chatSomeone} ${AppStrings.chatIsTyping}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ),
                      );
                    }

                    final messageIndex = typingUsers.isNotEmpty ? index - 1 : index;
                    final message = messages[messageIndex];

                    return MessageTile(
                      message: message,
                      currentUser: currentUser,
                      onLongPress: () => _showReactions(context, message),
                    );
                  },
                ),
              ),

              // Bottom Area (Input or Pending Request Banner)
              if (isPending)
                ChatPendingRequestBanner(
                  onDecline: () {
                    context.read<ChatBloc>().add(DeclineMessageRequestRequested(chatId: _activeChatId!));
                    Navigator.pop(context);
                  },
                  onAccept: () {
                    setState(() {
                      if (_chat != null) {
                        _chat = Chat(
                          id: _chat!.id,
                          participants: _chat!.participants,
                          status: 'accepted',
                          requestedBy: _chat!.requestedBy,
                          unreadCount: _chat!.unreadCount,
                          lastMessageTime: _chat!.lastMessageTime,
                          lastMessage: _chat!.lastMessage,
                        );
                      }
                    });
                    context.read<ChatBloc>().add(AcceptMessageRequestRequested(chatId: _activeChatId!));
                  },
                )
              else
                ChatInputArea(
                  controller: _messageController,
                  onTextChanged: _onTextChanged,
                  onPickMedia: _pickAndSendMedia,
                  onSendMessage: _sendMessage,
                ),
            ],
          );
        },
      ),
    );
  }
}
