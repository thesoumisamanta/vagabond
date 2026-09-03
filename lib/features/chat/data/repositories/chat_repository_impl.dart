import 'dart:io';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/domain/repositories/chat_repository.dart';
import 'package:vagabond/features/chat/data/datasources/chat_remote_datasource.dart';

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
  Future<List<Message>> getChatMessages({required String chatId, int page = 1, int limit = 50}) {
    return remoteDataSource.getChatMessages(chatId: chatId, page: page, limit: limit);
  }

  @override
  Future<Message> sendMediaMessage({required String chatId, required File media, String? text}) {
    return remoteDataSource.sendMediaMessage(chatId: chatId, media: media, text: text);
  }

  @override
  Future<Chat> acceptMessageRequest({required String chatId}) {
    return remoteDataSource.acceptMessageRequest(chatId: chatId);
  }

  @override
  Future<void> declineMessageRequest({required String chatId}) {
    return remoteDataSource.declineMessageRequest(chatId: chatId);
  }
}
