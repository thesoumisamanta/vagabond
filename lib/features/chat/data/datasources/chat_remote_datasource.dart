import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/features/chat/data/models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<ChatModel> getOrCreateChat({required String userId});
  Future<List<ChatModel>> getInboxChats();
  Future<List<MessageModel>> getChatMessages({required String chatId, int page = 1, int limit = 50});
  Future<MessageModel> sendMediaMessage({required String chatId, required File media, String? text});
  Future<ChatModel> acceptMessageRequest({required String chatId});
  Future<void> declineMessageRequest({required String chatId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ChatModel> getOrCreateChat({required String userId}) async {
    final response = await apiClient.get('${ApiEndpoints.chats}/user/$userId');
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    return ChatModel.fromJson(data['chat'] as Map<String, dynamic>);
  }

  @override
  Future<List<ChatModel>> getInboxChats() async {
    final response = await apiClient.get(ApiEndpoints.chats);
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final chatsJson = data['chats'] as List<dynamic>? ?? [];
    return chatsJson.map((c) => ChatModel.fromJson(c as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<MessageModel>> getChatMessages({required String chatId, int page = 1, int limit = 50}) async {
    final response = await apiClient.get(
      '${ApiEndpoints.chats}/$chatId/messages',
      queryParameters: {'page': page, 'limit': limit},
    );
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final messagesJson = data['messages'] as List<dynamic>? ?? [];
    return messagesJson.map((m) => MessageModel.fromJson(m as Map<String, dynamic>)).toList();
  }

  @override
  Future<MessageModel> sendMediaMessage({required String chatId, required File media, String? text}) async {
    final fileName = media.path.split('/').last;
    final formData = FormData.fromMap({
      'media': await MultipartFile.fromFile(media.path, filename: fileName),
      'text': ?text,
    });

    final response = await apiClient.post('${ApiEndpoints.chats}/$chatId/message', data: formData);
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    return MessageModel.fromJson(data['message'] as Map<String, dynamic>);
  }

  @override
  Future<ChatModel> acceptMessageRequest({required String chatId}) async {
    final response = await apiClient.post('${ApiEndpoints.chats}/$chatId/accept');
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    return ChatModel.fromJson(data['chat'] as Map<String, dynamic>);
  }

  @override
  Future<void> declineMessageRequest({required String chatId}) async {
    await apiClient.post('${ApiEndpoints.chats}/$chatId/decline');
  }
}
