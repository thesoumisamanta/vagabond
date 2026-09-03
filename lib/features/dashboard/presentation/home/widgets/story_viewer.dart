import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/story/domain/entities/story.dart';
import 'package:vagabond/features/story/presentation/bloc/story_bloc.dart';
import 'package:vagabond/features/story/presentation/bloc/story_event.dart';
import 'package:vagabond/features/story/presentation/bloc/story_state.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/features/dashboard/presentation/home/widgets/video_player_widget.dart';

class StoryViewer extends StatefulWidget {
  final UserStories userStories;

  const StoryViewer({super.key, required this.userStories});

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  final _replyController = TextEditingController();
  final _replyFocusNode = FocusNode();
  int _currentIndex = 0;
  bool _isReplying = false;
  DateTime? _tapDownTime;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);

    _showStory(index: 0);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.userStories.stories.length) {
            _currentIndex++;
            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            _showStory(index: _currentIndex);
          } else {
            Navigator.of(context).pop();
          }
        });
      }
    });

    _replyFocusNode.addListener(() {
      if (_replyFocusNode.hasFocus) {
        _animController.stop();
        setState(() {
          _isReplying = true;
        });
      } else {
        _animController.forward();
        setState(() {
          _isReplying = false;
        });
      }
    });
  }

  void _showStory({required int index}) {
    _animController.stop();
    _animController.reset();
    _animController.duration = const Duration(seconds: 5);
    _animController.forward();

    // Dispatch view story event
    final story = widget.userStories.stories[index];
    context.read<StoryBloc>().add(ViewStoryRequested(storyId: story.id));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final story = widget.userStories.stories[_currentIndex];
    context.read<StoryBloc>().add(ReplyToStoryRequested(storyId: story.id, text: text));
    _replyController.clear();
    _replyFocusNode.unfocus();
    CustomSnackBar.showSuccess(context, 'Reply sent');
  }

  void _deleteStory() {
    _animController.stop();
    final story = widget.userStories.stories[_currentIndex];
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text('Delete Story', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this story?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
              context.read<StoryBloc>().add(DeleteStoryRequested(storyId: story.id));
              Navigator.pop(context); // Close viewer
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ).then((value) {
      if (value != true && mounted) {
        _animController.forward();
      }
    });
  }

  void _showViewers() {
    _animController.stop();
    final story = widget.userStories.stories[_currentIndex];
    context.read<StoryBloc>().add(GetStoryViewersRequested(storyId: story.id));

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: context.read<StoryBloc>(),
          child: BlocBuilder<StoryBloc, StoryState>(
            builder: (context, state) {
              if (state is StoryLoading) {
                return const SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
                  ),
                );
              }
              if (state is StoryFailure) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(state.error, style: const TextStyle(color: Colors.white70)),
                  ),
                );
              }
              if (state is StoryViewersLoaded) {
                final viewers = state.viewers;
                return Container(
                  padding: const EdgeInsets.all(16),
                  height: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Viewers (${viewers.length})',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: viewers.isEmpty
                            ? const Center(
                                child: Text('No views yet', style: TextStyle(color: Colors.white54)),
                              )
                            : ListView.builder(
                                itemCount: viewers.length,
                                itemBuilder: (context, index) {
                                  final viewer = viewers[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: viewer.user.profilePictureUrl.isNotEmpty
                                          ? NetworkImage(viewer.user.profilePictureUrl)
                                          : null,
                                      child: viewer.user.profilePictureUrl.isEmpty
                                          ? Text(
                                              viewer.user.fullName.isNotEmpty
                                                  ? viewer.user.fullName[0].toUpperCase()
                                                  : 'U',
                                            )
                                          : null,
                                    ),
                                    title: Text(viewer.user.fullName, style: const TextStyle(color: Colors.white)),
                                    subtitle: Text(
                                      '@${viewer.user.username}',
                                      style: const TextStyle(color: Colors.white54),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox(height: 300);
            },
          ),
        );
      },
    ).whenComplete(() {
      _animController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storyUser = widget.userStories.user;
    final stories = widget.userStories.stories;
    final currentUser = context.read<AuthBloc>().currentUser;
    final isOwnStory = storyUser.id == currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Story Media PageView
          GestureDetector(
            onTapDown: (details) {
              if (_isReplying) {
                _replyFocusNode.unfocus();
                return;
              }
              _tapDownTime = DateTime.now();
              _animController.stop();
            },
            onTapCancel: () {
              _animController.forward();
            },
            onTapUp: (details) {
              if (_tapDownTime == null) return;
              final elapsed = DateTime.now().difference(_tapDownTime!);
              _animController.forward();

              if (elapsed.inMilliseconds < 300) {
                final width = MediaQuery.of(context).size.width;
                final dx = details.globalPosition.dx;
                if (dx < width / 3) {
                  // Go back
                  if (_currentIndex > 0) {
                    setState(() {
                      _currentIndex--;
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _showStory(index: _currentIndex);
                    });
                  }
                } else {
                  // Go forward
                  if (_currentIndex + 1 < stories.length) {
                    setState(() {
                      _currentIndex++;
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      _showStory(index: _currentIndex);
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                }
              }
            },
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Media
                    story.media.type == 'video'
                        ? VideoPlayerWidget(url: story.media.url)
                        : CachedNetworkImage(
                            imageUrl: story.media.url,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Center(child: Icon(Icons.error, color: Colors.white)),
                          ),
                    // Caption
                    if (story.caption.isNotEmpty)
                      Positioned(
                        bottom: isOwnStory ? 100 : 120,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            story.caption,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Top Bar (User details & progress indicators)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress Indicators
                  Row(
                    children: stories.asMap().entries.map((entry) {
                      final idx = entry.key;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              double val = 0.0;
                              if (idx < _currentIndex) {
                                val = 1.0;
                              } else if (idx == _currentIndex) {
                                val = _animController.value;
                              }
                              return LinearProgressIndicator(
                                value: val,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 2,
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // User Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        backgroundImage: storyUser.profilePictureUrl.isNotEmpty
                            ? CachedNetworkImageProvider(storyUser.profilePictureUrl)
                            : null,
                        child: storyUser.profilePictureUrl.isEmpty
                            ? Text(
                                storyUser.fullName.isNotEmpty ? storyUser.fullName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              storyUser.username,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              _formatTimeAgo(stories[_currentIndex].createdAt),
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (isOwnStory)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: _deleteStory,
                        ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar (Reply or Viewers)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black.withOpacity(0.5),
                child: isOwnStory
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: _showViewers,
                            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white70),
                            label: Text(
                              'Viewers (${stories[_currentIndex].viewsCount})',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              focusNode: _replyFocusNode,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Send message...',
                                hintStyle: const TextStyle(color: Colors.white54),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send, color: Color(0xFF6366F1)),
                            onPressed: _sendReply,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) {
      return AppStrings.homeJustNow;
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}${AppStrings.homeMinutesAgo}';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}${AppStrings.homeHoursAgo}';
    }
    return '${diff.inDays}${AppStrings.homeDaysAgo}';
  }
}
