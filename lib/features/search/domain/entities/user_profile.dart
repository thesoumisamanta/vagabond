import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/features/post/domain/entities/post.dart';

class UserProfile {
  final User user;
  final bool isFollowing;
  final List<Post> posts;

  const UserProfile({required this.user, required this.isFollowing, required this.posts});
}
