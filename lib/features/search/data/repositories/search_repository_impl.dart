import 'package:vagabond/features/search/domain/entities/search_user.dart';
import 'package:vagabond/features/search/domain/entities/user_profile.dart';
import 'package:vagabond/features/search/domain/repositories/search_repository.dart';
import 'package:vagabond/features/post/domain/entities/post.dart';
import 'package:vagabond/features/search/data/datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SearchUser>> searchUsers({required String query}) async {
    try {
      return await remoteDataSource.searchUsers(query: query);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserProfile> getUserProfile({required String id}) async {
    try {
      return await remoteDataSource.getUserProfile(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> toggleFollowUser({required String id}) async {
    try {
      return await remoteDataSource.toggleFollowUser(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SearchUser>> getFollowers({required String id}) async {
    try {
      return await remoteDataSource.getFollowers(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SearchUser>> getFollowing({required String id}) async {
    try {
      return await remoteDataSource.getFollowing(id: id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FeedResponse> getUserPosts({required String userId, int page = 1, int limit = 12}) async {
    try {
      return await remoteDataSource.getUserPosts(userId: userId, page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }
}
