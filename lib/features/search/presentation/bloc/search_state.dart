import 'package:vagabond/features/search/domain/entities/search_user.dart';
import 'package:vagabond/features/search/domain/entities/user_profile.dart';

abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchSuccess extends SearchState {
  final List<SearchUser> users;

  const SearchSuccess({required this.users});
}

class SearchFailure extends SearchState {
  final String error;

  const SearchFailure({required this.error});
}

class ProfileLoading extends SearchState {
  const ProfileLoading();
}

class ProfileSuccess extends SearchState {
  final UserProfile profile;

  const ProfileSuccess({required this.profile});
}

class ProfileFailure extends SearchState {
  final String error;

  const ProfileFailure({required this.error});
}

class FollowToggleInProgress extends SearchState {
  const FollowToggleInProgress();
}

class UserListLoading extends SearchState {
  const UserListLoading();
}

class UserListSuccess extends SearchState {
  final List<SearchUser> users;

  const UserListSuccess({required this.users});
}

class UserListFailure extends SearchState {
  final String error;

  const UserListFailure({required this.error});
}
