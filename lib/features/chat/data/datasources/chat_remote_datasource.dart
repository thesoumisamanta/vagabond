import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/features/chat/data/models/chat_model.dart';

class MessagesPaginationResponse {
  final List<MessageModel> messages;
  final bool hasMore;
  final String? nextCursor;

  const MessagesPaginationResponse({
    required this.messages,
    required this.hasMore,
    this.nextCursor,
  });
}

abstract class ChatRemoteDataSource {
  Future<ChatModel> getOrCreateChat({required String userId});
  Future<List<ChatModel>> getInboxChats();
  Future<MessagesPaginationResponse> getChatMessages({
    required String chatId,
    String? before,
    int limit = 50,
  });
  Future<MessageModel> sendMediaMessage({
    required String chatId,
    required File media,
    String? text,
    String? replyToId,
    String? messageType,
  });
  Future<ChatModel> acceptMessageRequest({required String chatId});
  Future<void> declineMessageRequest({required String chatId});
  Future<void> markMessagesAsRead({required String chatId});
  Future<void> reactMessage({required String messageId, required String emoji});
  Future<void> deleteMessage({required String messageId});
  Future<void> clearChatMessages({required String chatId});
  Future<List<MessageModel>> searchChatMessages({required String chatId, required String query});
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
  Future<MessagesPaginationResponse> getChatMessages({
    required String chatId,
    String? before,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (before != null && before.isNotEmpty) {
      queryParams['before'] = before;
    }

    final response = await apiClient.get(
      '${ApiEndpoints.chats}/$chatId/messages',
      queryParameters: queryParams,
    );
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final messagesJson = data['messages'] as List<dynamic>? ?? [];
    final messages = messagesJson.map((m) => MessageModel.fromJson(m as Map<String, dynamic>)).toList();
    final bool hasMore = data['hasMore'] as bool? ?? false;
    final String? nextCursor = data['nextCursor'] as String?;

    return MessagesPaginationResponse(
      messages: messages,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  @override
  Future<MessageModel> sendMediaMessage({
    required String chatId,
    required File media,
    String? text,
    String? replyToId,
    String? messageType,
  }) async {
    final fileName = media.path.split('/').last;
    final map = <String, dynamic>{
      'media': await MultipartFile.fromFile(media.path, filename: fileName),
      if (text != null && text.isNotEmpty) 'text': text,
      'replyToId': ?replyToId,
      'messageType': ?messageType,
    };

    final formData = FormData.fromMap(map);
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

  @override
  Future<void> markMessagesAsRead({required String chatId}) async {
    await apiClient.post('${ApiEndpoints.chats}/$chatId/read');
  }

  @override
  Future<void> reactMessage({required String messageId, required String emoji}) async {
    await apiClient.post('${ApiEndpoints.chats}/messages/$messageId/react', data: {'emoji': emoji});
  }

  @override
  Future<void> deleteMessage({required String messageId}) async {
    await apiClient.delete('${ApiEndpoints.chats}/messages/$messageId');
  }

  @override
  Future<void> clearChatMessages({required String chatId}) async {
    await apiClient.delete('${ApiEndpoints.chats}/$chatId/messages');
  }

  @override
  Future<List<MessageModel>> searchChatMessages({required String chatId, required String query}) async {
    final response = await apiClient.get(
      '${ApiEndpoints.chats}/$chatId/messages/search',
      queryParameters: {'q': query},
    );
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final messagesJson = data['messages'] as List<dynamic>? ?? [];
    return messagesJson.map((m) => MessageModel.fromJson(m as Map<String, dynamic>)).toList();
  }
}
