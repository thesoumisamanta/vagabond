import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/features/post/domain/entities/post.dart';
import 'package:vagabond/features/post/presentation/bloc/post_bloc.dart';
import 'package:vagabond/features/post/presentation/bloc/post_event.dart';
import 'package:vagabond/features/post/presentation/bloc/post_state.dart';
import 'package:vagabond/features/story/presentation/bloc/story_bloc.dart';
import 'package:vagabond/features/story/presentation/bloc/story_event.dart';
import 'package:vagabond/features/story/presentation/bloc/story_state.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/dashboard/presentation/home/widgets/stories_row.dart';
import 'package:vagabond/features/dashboard/presentation/home/widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchFeed(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchFeed({bool isRefresh = false}) {
    if (isRefresh) {
      _currentPage = 1;
      try {
        context.read<StoryBloc>().add(const GetFollowingStoriesRequested());
      } catch (_) {}
    }
    context.read<PostBloc>().add(GetFeedPostsRequested(page: _currentPage, isRefresh: isRefresh));
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<PostBloc>().state;
      if (state is FeedLoaded && !state.hasReachedMax) {
        _currentPage = state.currentPage + 1;
        _fetchFeed();
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _fetchFeed(isRefresh: true),
      color: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFF0F172A),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Stories Row Sliver
          SliverToBoxAdapter(
            child: BlocBuilder<StoryBloc, StoryState>(
              buildWhen: (previous, current) {
                return current is StoryInitial || current is StoryLoading || current is StoryLoaded;
              },
              builder: (context, state) {
                return StoriesRow(state: state);
              },
            ),
          ),

          // Feed Content Sliver
          BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              if (state is FeedLoading && _currentPage == 1) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
                  ),
                );
              }

              if (state is FeedFailure && _currentPage == 1) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.error,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchFeed(isRefresh: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(AppStrings.homeRetry, style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              List<Post> posts = [];
              bool hasReachedMax = false;

              if (state is FeedLoaded) {
                posts = state.posts;
                hasReachedMax = state.hasReachedMax;
              } else if (state is FeedLoading) {
                // Keep showing old posts while loading next page
                final blocState = context.read<PostBloc>().state;
                if (blocState is FeedLoaded) {
                  posts = blocState.posts;
                  hasReachedMax = blocState.hasReachedMax;
                }
              }

              if (posts.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                      child: Text(
                        AppStrings.homeNoPostsYet,
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index >= posts.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                          ),
                        ),
                      );
                    }

                    final post = posts[index];
                    return PostCard(post: post);
                  }, childCount: posts.length + (hasReachedMax ? 0 : 1)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
