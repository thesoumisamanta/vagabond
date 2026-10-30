import 'dart:io';
import 'package:vagabond/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';

abstract class ChatRepository {
  Future<Chat> getOrCreateChat({required String userId});
  Future<List<Chat>> getInboxChats();
  Future<MessagesPaginationResponse> getChatMessages({
    required String chatId,
    String? before,
    int limit = 50,
  });
  Future<Message> sendMediaMessage({
    required String chatId,
    required File media,
    String? text,
    String? replyToId,
    String? messageType,
  });
  Future<Chat> acceptMessageRequest({required String chatId});
  Future<void> declineMessageRequest({required String chatId});
  Future<void> markMessagesAsRead({required String chatId});
  Future<void> reactMessage({required String messageId, required String emoji});
  Future<void> deleteMessage({required String messageId});
  Future<void> clearChatMessages({required String chatId});
  Future<List<Message>> searchChatMessages({required String chatId, required String query});
}
