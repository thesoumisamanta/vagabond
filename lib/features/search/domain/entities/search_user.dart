class SearchUser {
  final String id;
  final String username;
  final String fullName;
  final String profilePicture;
  final String accountType;
  final bool isVerified;

  const SearchUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.profilePicture,
    required this.accountType,
    required this.isVerified,
  });
}
