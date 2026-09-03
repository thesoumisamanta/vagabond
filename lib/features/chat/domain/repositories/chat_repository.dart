import 'dart:io';
import 'package:vagabond/features/chat/domain/entities/chat.dart';

abstract class ChatRepository {
  Future<Chat> getOrCreateChat({required String userId});
  Future<List<Chat>> getInboxChats();
  Future<List<Message>> getChatMessages({required String chatId, int page = 1, int limit = 50});
  Future<Message> sendMediaMessage({required String chatId, required File media, String? text});
  Future<Chat> acceptMessageRequest({required String chatId});
  Future<void> declineMessageRequest({required String chatId});
}
