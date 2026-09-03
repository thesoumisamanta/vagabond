import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as socketclient;
import 'package:vagabond/core/network/api_endpoints.dart';

class SocketService {
  socketclient.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _readController = StreamController<Map<String, dynamic>>.broadcast();
  final _reactionController = StreamController<Map<String, dynamic>>.broadcast();
  final _deleteController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _stopTypingController = StreamController<Map<String, dynamic>>.broadcast();
  final _onlineController = StreamController<Map<String, dynamic>>.broadcast();
  final _offlineController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onMessageReceived => _messageController.stream;
  Stream<Map<String, dynamic>> get onMessagesRead => _readController.stream;
  Stream<Map<String, dynamic>> get onMessageReacted => _reactionController.stream;
  Stream<Map<String, dynamic>> get onMessageDeleted => _deleteController.stream;
  Stream<Map<String, dynamic>> get onUserTyping => _typingController.stream;
  Stream<Map<String, dynamic>> get onUserStopTyping => _stopTypingController.stream;
  Stream<Map<String, dynamic>> get onUserOnline => _onlineController.stream;
  Stream<Map<String, dynamic>> get onUserOffline => _offlineController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }

    _socket = socketclient.io(
      ApiEndpoints.baseUrl,
      socketclient.OptionBuilder().setTransports(['websocket']).setAuth({'token': token}).disableAutoConnect().build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Socket connected successfully');
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket disconnected');
    });

    _socket!.onConnectError((data) {
      debugPrint('Socket connection error: $data');
    });

    // Event Listeners
    _socket!.on('receive_message', (data) {
      if (data is Map<String, dynamic>) {
        _messageController.add(data);
      }
    });

    _socket!.on('messages_read', (data) {
      if (data is Map<String, dynamic>) {
        _readController.add(data);
      }
    });

    _socket!.on('message_reacted', (data) {
      if (data is Map<String, dynamic>) {
        _reactionController.add(data);
      }
    });

    _socket!.on('message_deleted', (data) {
      if (data is Map<String, dynamic>) {
        _deleteController.add(data);
      }
    });

    _socket!.on('user_typing', (data) {
      if (data is Map<String, dynamic>) {
        _typingController.add(data);
      }
    });

    _socket!.on('user_stop_typing', (data) {
      if (data is Map<String, dynamic>) {
        _stopTypingController.add(data);
      }
    });

    _socket!.on('user_online', (data) {
      if (data is Map<String, dynamic>) {
        _onlineController.add(data);
      }
    });

    _socket!.on('user_offline', (data) {
      if (data is Map<String, dynamic>) {
        _offlineController.add(data);
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void sendMessage({
    required String chatId,
    required String text,
    String? sharedPostId,
    String? sharedStoryId,
    required Function(Map<String, dynamic>) onAck,
  }) {
    if (_socket == null || !_socket!.connected) return;

    _socket!.emitWithAck(
      'send_message',
      {'chatId': chatId, 'text': text, 'sharedPostId': sharedPostId, 'sharedStoryId': sharedStoryId},
      ack: (ack) {
        if (ack is Map<String, dynamic>) {
          onAck(ack);
        } else if (ack is Map) {
          onAck(Map<String, dynamic>.from(ack));
        }
      },
    );
  }

  void markRead({required String chatId}) {
    _socket?.emit('mark_read', {'chatId': chatId});
  }

  void reactMessage({required String messageId, required String emoji}) {
    _socket?.emit('react_message', {'messageId': messageId, 'emoji': emoji});
  }

  void deleteMessage({required String messageId}) {
    _socket?.emit('delete_message', {'messageId': messageId});
  }

  void typing({required String chatId}) {
    _socket?.emit('typing', {'chatId': chatId});
  }

  void stopTyping({required String chatId}) {
    _socket?.emit('stop_typing', {'chatId': chatId});
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _readController.close();
    _reactionController.close();
    _deleteController.close();
    _typingController.close();
    _stopTypingController.close();
    _onlineController.close();
    _offlineController.close();
  }
}
