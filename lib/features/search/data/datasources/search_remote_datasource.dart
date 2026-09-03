import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/features/post/data/models/post_model.dart';
import 'package:vagabond/features/search/data/models/search_user_model.dart';
import 'package:vagabond/features/search/data/models/user_profile_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchUserModel>> searchUsers({required String query});
  Future<UserProfileModel> getUserProfile({required String id});
  Future<bool> toggleFollowUser({required String id});
  Future<List<SearchUserModel>> getFollowers({required String id});
  Future<List<SearchUserModel>> getFollowing({required String id});
  Future<FeedResponseModel> getUserPosts({required String userId, int page = 1, int limit = 12});
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiClient apiClient;

  SearchRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SearchUserModel>> searchUsers({required String query}) async {
    final response = await apiClient.get('users/search', queryParameters: {'query': query});

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final usersList = data['users'] as List? ?? [];

    return usersList.map((item) => SearchUserModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<UserProfileModel> getUserProfile({required String id}) async {
    final response = await apiClient.get('users/profile/$id');
    return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> toggleFollowUser({required String id}) async {
    final response = await apiClient.post('users/follow/$id');
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    return data['isFollowing'] ?? false;
  }

  @override
  Future<List<SearchUserModel>> getFollowers({required String id}) async {
    final response = await apiClient.get('users/$id/followers');
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final followersList = data['followers'] as List? ?? [];

    return followersList.map((item) => SearchUserModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SearchUserModel>> getFollowing({required String id}) async {
    final response = await apiClient.get('users/$id/following');
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final followingList = data['following'] as List? ?? [];

    return followingList.map((item) => SearchUserModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<FeedResponseModel> getUserPosts({required String userId, int page = 1, int limit = 12}) async {
    final response = await apiClient.get('posts/user/$userId', queryParameters: {'page': page, 'limit': limit});
    return FeedResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
