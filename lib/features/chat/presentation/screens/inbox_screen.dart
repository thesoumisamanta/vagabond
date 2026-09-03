import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_event.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_state.dart';
import 'package:vagabond/features/chat/presentation/widgets/inbox_chat_tile.dart';
import 'package:vagabond/features/chat/presentation/widgets/inbox_empty_state.dart';
import 'package:vagabond/features/chat/presentation/widgets/inbox_error_state.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<Chat> _cachedChats = [];

  @override
  void initState() {
    super.initState();
    _fetchInbox();
  }

  @override
  void didUpdateWidget(InboxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-fetch when widget is re-shown (e.g., tab switch back)
    _fetchInbox();
  }

  void _fetchInbox() {
    context.read<ChatBloc>().add(const GetInboxChatsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthBloc>().currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                AppStrings.chatInboxTitle,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Chats List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _fetchInbox();
                  },
                  color: const Color(0xFF6366F1),
                  backgroundColor: const Color(0xFF0F172A),
                  child: BlocConsumer<ChatBloc, ChatState>(
                    listenWhen: (previous, current) => current is InboxChatsLoaded,
                    listener: (context, state) {
                      if (state is InboxChatsLoaded) {
                        setState(() {
                          _cachedChats = state.chats;
                        });
                      }
                    },
                    buildWhen: (previous, current) =>
                        current is ChatLoading || current is InboxChatsLoaded || current is ChatFailure,
                    builder: (context, state) {
                      if (state is ChatLoading && _cachedChats.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                          ),
                        );
                      }

                      if (state is ChatFailure) {
                        return InboxErrorState(error: state.error, onRetry: _fetchInbox);
                      }

                      final chats = _cachedChats;
                      if (chats.isEmpty) {
                        return const InboxEmptyState();
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return InboxChatTile(
                            chat: chat,
                            currentUser: currentUser,
                            onTap: () async {
                              await context.push('/chat/${chat.id}', extra: chat);
                              _fetchInbox();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
