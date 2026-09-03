import 'package:vagabond/features/auth/data/models/user_model.dart';
import 'package:vagabond/features/search/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({required UserModel super.user, required super.isFollowing, super.posts = const []});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final userJson = data['user'] as Map<String, dynamic>? ?? {};
    return UserProfileModel(user: UserModel.fromJson(userJson), isFollowing: data['isFollowing'] ?? false);
  }
}
