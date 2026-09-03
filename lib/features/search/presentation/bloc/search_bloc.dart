import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/features/search/domain/entities/user_profile.dart';
import 'package:vagabond/features/search/domain/repositories/search_repository.dart';
import 'package:vagabond/features/post/domain/entities/post.dart';
import 'package:vagabond/features/search/presentation/bloc/search_event.dart';
import 'package:vagabond/features/search/presentation/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository searchRepository;

  SearchBloc({required this.searchRepository}) : super(const SearchInitial()) {
    on<SearchUsersRequested>(_onSearchUsersRequested);
    on<GetUserProfileRequested>(_onGetUserProfileRequested);
    on<ToggleFollowRequested>(_onToggleFollowRequested);
    on<GetFollowersRequested>(_onGetFollowersRequested);
    on<GetFollowingRequested>(_onGetFollowingRequested);
  }

  Future<void> _onSearchUsersRequested(SearchUsersRequested event, Emitter<SearchState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());
    try {
      final users = await searchRepository.searchUsers(query: event.query);
      emit(SearchSuccess(users: users));
    } catch (e) {
      emit(SearchFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetUserProfileRequested(GetUserProfileRequested event, Emitter<SearchState> emit) async {
    emit(const ProfileLoading());
    try {
      final profile = await searchRepository.getUserProfile(id: event.id);
      List<Post> posts = [];
      try {
        final postsResponse = await searchRepository.getUserPosts(userId: event.id);
        posts = postsResponse.posts;
      } catch (_) {}
      final updatedProfile = UserProfile(user: profile.user, isFollowing: profile.isFollowing, posts: posts);
      emit(ProfileSuccess(profile: updatedProfile));
    } catch (e) {
      emit(ProfileFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onToggleFollowRequested(ToggleFollowRequested event, Emitter<SearchState> emit) async {
    final currentState = state;
    if (currentState is ProfileSuccess) {
      final profile = currentState.profile;
      final user = profile.user;

      try {
        final isFollowing = await searchRepository.toggleFollowUser(id: event.id);

        final newFollowersCount = isFollowing
            ? user.followersCount + 1
            : (user.followersCount > 0 ? user.followersCount - 1 : 0);

        final updatedUser = user.copyWith(followersCount: newFollowersCount);

        final updatedProfile = UserProfile(user: updatedUser, isFollowing: isFollowing, posts: profile.posts);

        emit(ProfileSuccess(profile: updatedProfile));
      } catch (e) {
        emit(ProfileSuccess(profile: profile));
      }
    }
  }

  Future<void> _onGetFollowersRequested(GetFollowersRequested event, Emitter<SearchState> emit) async {
    emit(const UserListLoading());
    try {
      final users = await searchRepository.getFollowers(id: event.id);
      emit(UserListSuccess(users: users));
    } catch (e) {
      emit(UserListFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGetFollowingRequested(GetFollowingRequested event, Emitter<SearchState> emit) async {
    emit(const UserListLoading());
    try {
      final users = await searchRepository.getFollowing(id: event.id);
      emit(UserListSuccess(users: users));
    } catch (e) {
      emit(UserListFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
