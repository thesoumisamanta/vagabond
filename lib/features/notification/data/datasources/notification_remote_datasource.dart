import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/features/notification/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationListResponseModel> getNotifications({int page = 1, int limit = 20});
  Future<void> markAsRead({required String id});
  Future<void> markAllAsRead();
  Future<void> deleteNotification({required String id});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<NotificationListResponseModel> getNotifications({int page = 1, int limit = 20}) async {
    final response = await apiClient.get(ApiEndpoints.notifications, queryParameters: {'page': page, 'limit': limit});
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    return NotificationListResponseModel.fromJson(data);
  }

  @override
  Future<void> markAsRead({required String id}) async {
    await apiClient.put('${ApiEndpoints.notifications}/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await apiClient.put('${ApiEndpoints.notifications}/read-all');
  }

  @override
  Future<void> deleteNotification({required String id}) async {
    await apiClient.delete('${ApiEndpoints.notifications}/$id');
  }
}
