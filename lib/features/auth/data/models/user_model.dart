import 'package:vagabond/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.fullName,
    required super.accountType,
    required super.bio,
    required super.profilePictureUrl,
    required super.coverPhotoUrl,
    required super.location,
    required super.website,
    required super.followersCount,
    required super.followingCount,
    required super.postsCount,
    required super.isVerified,
    required super.isEmailVerified,
    required super.isPrivate,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      accountType: json['accountType'] ?? '',
      bio: json['bio'] ?? '',
      profilePictureUrl: json['profilePicture']?['url'] ?? '',
      coverPhotoUrl: json['coverPhoto']?['url'] ?? '',
      location: json['location'] ?? '',
      website: json['website'] ?? '',
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'accountType': accountType,
      'bio': bio,
      'profilePicture': {'url': profilePictureUrl},
      'coverPhoto': {'url': coverPhotoUrl},
      'location': location,
      'website': website,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isVerified': isVerified,
      'isEmailVerified': isEmailVerified,
      'isPrivate': isPrivate,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      fullName: entity.fullName,
      accountType: entity.accountType,
      bio: entity.bio,
      profilePictureUrl: entity.profilePictureUrl,
      coverPhotoUrl: entity.coverPhotoUrl,
      location: entity.location,
      website: entity.website,
      followersCount: entity.followersCount,
      followingCount: entity.followingCount,
      postsCount: entity.postsCount,
      isVerified: entity.isVerified,
      isEmailVerified: entity.isEmailVerified,
      isPrivate: entity.isPrivate,
      createdAt: entity.createdAt,
    );
  }
}
