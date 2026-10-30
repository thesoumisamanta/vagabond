import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_event.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_state.dart';
import 'package:vagabond/features/chat/presentation/widgets/inbox_chat_tile.dart';
import 'package:vagabond/features/chat/presentation/widgets/inbox_empty_state.dart';
import 'package:vagabond/features/chat/presentation/widgets/inbox_error_state.dart';
import 'package:vagabond/features/chat/presentation/widgets/whatsapp_theme.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Chat> _cachedChats = [];
  Map<String, bool> _typingChats = {};
  bool _isSearchActive = false;
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All' | 'Unread'

  @override
  void initState() {
    super.initState();
    _fetchInbox();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchInbox() {
    context.read<ChatBloc>().add(const GetInboxChatsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthBloc>().currentUser;

    return Scaffold(
      backgroundColor: WhatsAppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: WhatsAppTheme.headerBackground,
        elevation: 1,
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: WhatsAppTheme.textPrimary, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: TextStyle(color: WhatsAppTheme.textSecondary),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              )
            : const Text(
                'Chats',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: WhatsAppTheme.textPrimary,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search, color: WhatsAppTheme.textPrimary),
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          if (!_isSearchActive)
            IconButton(
              icon: const Icon(Icons.more_vert, color: WhatsAppTheme.textPrimary),
              onPressed: () {},
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: WhatsAppTheme.sendFabGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => context.push('/search'),
        child: const Icon(Icons.chat),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // WhatsApp Filter Tabs ("All", "Unread")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Unread'),
                ],
              ),
            ),

            // Chats List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _fetchInbox(),
                color: WhatsAppTheme.primaryGreen,
                backgroundColor: WhatsAppTheme.cardBackground,
                child: BlocConsumer<ChatBloc, ChatState>(
                  listenWhen: (previous, current) => current is InboxChatsLoaded,
                  listener: (context, state) {
                    if (state is InboxChatsLoaded) {
                      setState(() {
                        _cachedChats = state.chats;
                        _typingChats = state.typingChats;
                      });
                    }
                  },
                  buildWhen: (previous, current) =>
                      current is ChatLoading || current is InboxChatsLoaded || current is ChatFailure,
                  builder: (context, state) {
                    if (state is ChatLoading && _cachedChats.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(WhatsAppTheme.primaryGreen),
                        ),
                      );
                    }

                    if (state is ChatFailure && _cachedChats.isEmpty) {
                      return InboxErrorState(error: state.error, onRetry: _fetchInbox);
                    }

                    // Apply filters & search
                    var filteredChats = _cachedChats;

                    if (_selectedFilter == 'Unread') {
                      filteredChats = filteredChats.where((c) {
                        final unread = c.unreadCount[currentUser?.id] ?? 0;
                        return unread > 0;
                      }).toList();
                    }

                    if (_searchQuery.isNotEmpty) {
                      filteredChats = filteredChats.where((c) {
                        final other = c.participants.cast<ChatParticipant?>().firstWhere(
                              (p) => p?.id != currentUser?.id,
                              orElse: () => null,
                            );
                        final name = other?.fullName.toLowerCase() ?? '';
                        final username = other?.username.toLowerCase() ?? '';
                        final lastMsg = c.lastMessage?.text.toLowerCase() ?? '';
                        final q = _searchQuery.toLowerCase();
                        return name.contains(q) || username.contains(q) || lastMsg.contains(q);
                      }).toList();
                    }

                    if (filteredChats.isEmpty) {
                      return const InboxEmptyState();
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final isTyping = _typingChats[chat.id] ?? false;

                        return InboxChatTile(
                          chat: chat,
                          currentUser: currentUser,
                          isTyping: isTyping,
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
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? WhatsAppTheme.myMessageBubble : WhatsAppTheme.inputBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? WhatsAppTheme.primaryGreen : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? WhatsAppTheme.brightGreen : WhatsAppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
