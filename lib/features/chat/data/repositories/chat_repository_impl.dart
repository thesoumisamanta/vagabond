import 'dart:io';
import 'package:vagabond/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Chat> getOrCreateChat({required String userId}) {
    return remoteDataSource.getOrCreateChat(userId: userId);
  }

  @override
  Future<List<Chat>> getInboxChats() {
    return remoteDataSource.getInboxChats();
  }

  @override
  Future<MessagesPaginationResponse> getChatMessages({
    required String chatId,
    String? before,
    int limit = 50,
  }) {
    return remoteDataSource.getChatMessages(chatId: chatId, before: before, limit: limit);
  }

  @override
  Future<Message> sendMediaMessage({
    required String chatId,
    required File media,
    String? text,
    String? replyToId,
    String? messageType,
  }) {
    return remoteDataSource.sendMediaMessage(
      chatId: chatId,
      media: media,
      text: text,
      replyToId: replyToId,
      messageType: messageType,
    );
  }

  @override
  Future<Chat> acceptMessageRequest({required String chatId}) {
    return remoteDataSource.acceptMessageRequest(chatId: chatId);
  }

  @override
  Future<void> declineMessageRequest({required String chatId}) {
    return remoteDataSource.declineMessageRequest(chatId: chatId);
  }

  @override
  Future<void> markMessagesAsRead({required String chatId}) {
    return remoteDataSource.markMessagesAsRead(chatId: chatId);
  }

  @override
  Future<void> reactMessage({required String messageId, required String emoji}) {
    return remoteDataSource.reactMessage(messageId: messageId, emoji: emoji);
  }

  @override
  Future<void> deleteMessage({required String messageId}) {
    return remoteDataSource.deleteMessage(messageId: messageId);
  }

  @override
  Future<void> clearChatMessages({required String chatId}) {
    return remoteDataSource.clearChatMessages(chatId: chatId);
  }

  @override
  Future<List<Message>> searchChatMessages({required String chatId, required String query}) {
    return remoteDataSource.searchChatMessages(chatId: chatId, query: query);
  }
}
