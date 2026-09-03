import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/features/search/presentation/bloc/search_bloc.dart';
import 'package:vagabond/features/search/presentation/bloc/search_event.dart';
import 'package:vagabond/features/search/presentation/bloc/search_state.dart';
import 'package:vagabond/features/search/presentation/widgets/user_list_item.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class UserListScreen extends StatefulWidget {
  final String userId;
  final String type; // 'followers' or 'following'

  const UserListScreen({super.key, required this.userId, required this.type});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.type == 'followers') {
      context.read<SearchBloc>().add(GetFollowersRequested(id: widget.userId));
    } else {
      context.read<SearchBloc>().add(GetFollowingRequested(id: widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'followers' ? AppStrings.searchFollowersTitle : AppStrings.searchFollowingTitle;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        child: SafeArea(
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is UserListLoading) {
                return const Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
                );
              }

              if (state is UserListFailure) {
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

              if (state is UserListSuccess) {
                final users = state.users;
                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      widget.type == 'followers' ? AppStrings.searchNoFollowers : AppStrings.searchNoFollowing,
                      style: const TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserListItem(user: user, onTap: () => context.push('/profile/${user.id}'));
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
