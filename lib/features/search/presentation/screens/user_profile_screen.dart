import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/search/presentation/bloc/search_bloc.dart';
import 'package:vagabond/features/search/presentation/bloc/search_event.dart';
import 'package:vagabond/features/search/presentation/bloc/search_state.dart';
import 'package:vagabond/features/search/presentation/widgets/profile_header.dart';
import 'package:vagabond/features/search/presentation/widgets/profile_stats.dart';
import 'package:vagabond/features/search/presentation/widgets/private_account_placeholder.dart';
import 'package:vagabond/features/search/presentation/widgets/profile_posts_grid.dart';
import 'package:vagabond/features/story/presentation/widgets/story_highlights_section.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  void _showUnfollowConfirmation(BuildContext context, String username, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF0F172A).withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            title: const Text(
              AppStrings.searchUnfollowTitle,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Text(
              '${AppStrings.searchUnfollowConfirmPrefix}$username${AppStrings.searchUnfollowConfirmSuffix}',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(AppStrings.searchCancel, style: TextStyle(color: Colors.white.withOpacity(0.6))),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onConfirm();
                },
                child: const Text(
                  AppStrings.searchUnfollowButton,
                  style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(GetUserProfileRequested(id: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          AppStrings.searchProfileTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0F172A)],
          ),
        ),
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
              );
            }

            if (state is ProfileFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    state.error,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is ProfileSuccess) {
              final profile = state.profile;
              final user = profile.user;
              final isSelf = context.read<AuthBloc>().currentUser?.id == user.id;
              final isPrivateAndNotFollowing = user.isPrivate && !profile.isFollowing && !isSelf;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(
                      user: user,
                      isFollowing: profile.isFollowing,
                      isSelf: isSelf,
                      onFollowToggle: () {
                        if (profile.isFollowing) {
                          _showUnfollowConfirmation(context, user.username, () {
                            context.read<SearchBloc>().add(ToggleFollowRequested(id: user.id));
                          });
                        } else {
                          context.read<SearchBloc>().add(ToggleFollowRequested(id: user.id));
                        }
                      },
                      onMessageTap: () {
                        context.push('/chat/user/${user.id}');
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileStats(
                            user: user,
                            isPrivateAndNotFollowing: isPrivateAndNotFollowing,
                            onFollowersTap: () => context.push('/profile/${user.id}/users-list?type=followers'),
                            onFollowingTap: () => context.push('/profile/${user.id}/users-list?type=following'),
                          ),
                          if (!isPrivateAndNotFollowing) ...[
                            const SizedBox(height: 16),
                            StoryHighlightsSection(userId: user.id),
                            const SizedBox(height: 24),
                            ProfilePostsGrid(
                              posts: profile.posts,
                              onPostTap: (post) => context.push('/post/${post.id}'),
                            ),
                          ] else ...[
                            const SizedBox(height: 24),
                            const PrivateAccountPlaceholder(),
                          ],
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
