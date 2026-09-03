import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vagabond/features/post/presentation/bloc/post_bloc.dart';
import 'package:vagabond/features/post/presentation/bloc/post_event.dart';
import 'package:vagabond/features/post/presentation/bloc/post_state.dart';
import 'package:vagabond/features/post/presentation/widgets/post_details_card.dart';
import 'package:vagabond/features/comment/presentation/widgets/comments_sheet.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(GetPostDetailsRequested(id: widget.postId));
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
          AppStrings.postDetailsTitle,
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
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
              );
            }

            if (state is PostDetailsFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.error,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<PostBloc>().add(GetPostDetailsRequested(id: widget.postId));
                        },
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

            if (state is PostDetailsSuccess) {
              final post = state.post;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: PostDetailsCard(
                    post: post,
                    onLike: () {
                      context.read<PostBloc>().add(LikePostRequested(id: post.id));
                    },
                    onDislike: () {
                      context.read<PostBloc>().add(DislikePostRequested(id: post.id));
                    },
                    onComment: () {
                      CommentsSheet.show(context, post.id);
                    },
                    onShare: () {
                      // Notify server
                      context.read<PostBloc>().add(SharePostRequested(id: post.id));
                      // Open native share sheet
                      final shareUrl = 'https://traveldiary.clipboux.online/post/${post.id}';
                      final caption = post.caption.isNotEmpty ? '${post.caption}\n\n' : '';
                      Share.share(
                        '$caption${AppStrings.homeSharePrefix}$shareUrl',
                        subject: AppStrings.homeShareSubject,
                      );
                    },
                  ),
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
