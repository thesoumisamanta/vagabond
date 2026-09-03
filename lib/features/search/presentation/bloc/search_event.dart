abstract class SearchEvent {
  const SearchEvent();
}

class SearchUsersRequested extends SearchEvent {
  final String query;

  const SearchUsersRequested({required this.query});
}

class GetUserProfileRequested extends SearchEvent {
  final String id;

  const GetUserProfileRequested({required this.id});
}

class ToggleFollowRequested extends SearchEvent {
  final String id;

  const ToggleFollowRequested({required this.id});
}

class GetFollowersRequested extends SearchEvent {
  final String id;

  const GetFollowersRequested({required this.id});
}

class GetFollowingRequested extends SearchEvent {
  final String id;

  const GetFollowingRequested({required this.id});
}
