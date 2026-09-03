class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String accountType;
  final String bio;
  final String profilePictureUrl;
  final String coverPhotoUrl;
  final String location;
  final String website;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isVerified;
  final bool isEmailVerified;
  final bool isPrivate;
  final String createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.accountType,
    required this.bio,
    required this.profilePictureUrl,
    required this.coverPhotoUrl,
    required this.location,
    required this.website,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.isVerified,
    required this.isEmailVerified,
    required this.isPrivate,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? accountType,
    String? bio,
    String? profilePictureUrl,
    String? coverPhotoUrl,
    String? location,
    String? website,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isVerified,
    bool? isEmailVerified,
    bool? isPrivate,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      accountType: accountType ?? this.accountType,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      location: location ?? this.location,
      website: website ?? this.website,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isVerified: isVerified ?? this.isVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
