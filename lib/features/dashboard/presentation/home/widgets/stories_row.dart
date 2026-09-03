import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/story/domain/entities/story.dart';
import 'package:vagabond/features/story/presentation/bloc/story_bloc.dart';
import 'package:vagabond/features/story/presentation/bloc/story_event.dart';
import 'package:vagabond/features/story/presentation/bloc/story_state.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/dashboard/presentation/home/widgets/story_viewer.dart';

class StoriesRow extends StatelessWidget {
  final StoryState state;

  const StoriesRow({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().currentUser;

    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Current user's "Add Story" item
          GestureDetector(
            onTap: () async {
              final result = await context.push('/create-story');
              if (result == true && context.mounted) {
                context.read<StoryBloc>().add(const GetFollowingStoriesRequested());
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                          backgroundImage: user != null && user.profilePictureUrl.isNotEmpty
                              ? NetworkImage(user.profilePictureUrl)
                              : null,
                          child: user == null || user.profilePictureUrl.isEmpty
                              ? Text(
                                  user != null && user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(AppStrings.homeYourStory, style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ),

          // Following stories list
          if (state is StoryLoading)
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 45,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (state is StoryLoaded) ...[
            ...((state as StoryLoaded).userStories).map((userStory) {
              final hasUnviewed = userStory.stories.any((s) => !s.hasViewed);
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    if (userStory.stories.isNotEmpty) {
                      _showStoryViewer(context, userStory);
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: hasUnviewed
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF818CF8), // Indigo 400
                                    Color(0xFFC084FC), // Purple 400
                                    Color(0xFFF472B6), // Pink 400
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          border: !hasUnviewed ? Border.all(color: Colors.white.withOpacity(0.2), width: 1.5) : null,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Color(0xFF0F172A), shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            backgroundImage: userStory.user.profilePictureUrl.isNotEmpty
                                ? CachedNetworkImageProvider(userStory.user.profilePictureUrl)
                                : null,
                            child: userStory.user.profilePictureUrl.isEmpty
                                ? Text(
                                    userStory.user.fullName.isNotEmpty ? userStory.user.fullName[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 70,
                        child: Text(
                          userStory.user.username,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _showStoryViewer(BuildContext context, UserStories userStories) {
    final storyBloc = context.read<StoryBloc>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppStrings.homeStoryViewerBarrierLabel,
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, anim1, anim2) {
        return BlocProvider.value(
          value: storyBloc,
          child: StoryViewer(userStories: userStories),
        );
      },
    ).then((_) {
      if (context.mounted) {
        storyBloc.add(const GetFollowingStoriesRequested());
      }
    });
  }
}
