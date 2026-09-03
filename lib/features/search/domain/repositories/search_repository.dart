import 'package:vagabond/features/search/domain/entities/search_user.dart';
import 'package:vagabond/features/search/domain/entities/user_profile.dart';
import 'package:vagabond/features/post/domain/entities/post.dart';

abstract class SearchRepository {
  Future<List<SearchUser>> searchUsers({required String query});
  Future<UserProfile> getUserProfile({required String id});
  Future<bool> toggleFollowUser({required String id});
  Future<List<SearchUser>> getFollowers({required String id});
  Future<List<SearchUser>> getFollowing({required String id});
  Future<FeedResponse> getUserPosts({required String userId, int page = 1, int limit = 12});
}
