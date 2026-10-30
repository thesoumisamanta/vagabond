import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as socketclient;
import 'package:vagabond/core/network/api_endpoints.dart';

class SocketService {
  socketclient.Socket? _socket;

  // Stream Controllers
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _newSentMessageController = StreamController<Map<String, dynamic>>.broadcast();
  final _deliveredController = StreamController<Map<String, dynamic>>.broadcast();
  final _readController = StreamController<Map<String, dynamic>>.broadcast();
  final _reactionController = StreamController<Map<String, dynamic>>.broadcast();
  final _deleteController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _stopTypingController = StreamController<Map<String, dynamic>>.broadcast();
  final _onlineController = StreamController<Map<String, dynamic>>.broadcast();
  final _offlineController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatClearedController = StreamController<Map<String, dynamic>>.broadcast();
  final _requestAcceptedController = StreamController<Map<String, dynamic>>.broadcast();
  final _requestDeclinedController = StreamController<Map<String, dynamic>>.broadcast();

  // Stream Getters
  Stream<Map<String, dynamic>> get onMessageReceived => _messageController.stream;
  Stream<Map<String, dynamic>> get onNewSentMessage => _newSentMessageController.stream;
  Stream<Map<String, dynamic>> get onMessageDelivered => _deliveredController.stream;
  Stream<Map<String, dynamic>> get onMessagesRead => _readController.stream;
  Stream<Map<String, dynamic>> get onMessageReacted => _reactionController.stream;
  Stream<Map<String, dynamic>> get onMessageDeleted => _deleteController.stream;
  Stream<Map<String, dynamic>> get onUserTyping => _typingController.stream;
  Stream<Map<String, dynamic>> get onUserStopTyping => _stopTypingController.stream;
  Stream<Map<String, dynamic>> get onUserOnline => _onlineController.stream;
  Stream<Map<String, dynamic>> get onUserOffline => _offlineController.stream;
  Stream<Map<String, dynamic>> get onChatCleared => _chatClearedController.stream;
  Stream<Map<String, dynamic>> get onChatRequestAccepted => _requestAcceptedController.stream;
  Stream<Map<String, dynamic>> get onChatRequestDeclined => _requestDeclinedController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }

    _socket = socketclient.io(
      ApiEndpoints.baseUrl,
      socketclient.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('✅ Socket connected successfully: ${_socket?.id}');
    });

    _socket!.onDisconnect((_) {
      debugPrint('🔌 Socket disconnected');
    });

    _socket!.onConnectError((data) {
      debugPrint('❌ Socket connection error: $data');
    });

    // 1. Incoming Message from someone else
    _socket!.on('receive_message', (data) {
      if (data is Map) {
        _messageController.add(Map<String, dynamic>.from(data));
      }
    });

    // 2. Multi-device sync for own message sent on another device
    _socket!.on('new_sent_message', (data) {
      if (data is Map) {
        _newSentMessageController.add(Map<String, dynamic>.from(data));
      }
    });

    // 3. Message delivered tick
    _socket!.on('message_delivered', (data) {
      if (data is Map) {
        _deliveredController.add(Map<String, dynamic>.from(data));
      }
    });

    // 4. Messages read tick (double blue)
    _socket!.on('messages_read', (data) {
      if (data is Map) {
        _readController.add(Map<String, dynamic>.from(data));
      }
    });

    // 5. Message reaction update
    _socket!.on('message_reacted', (data) {
      if (data is Map) {
        _reactionController.add(Map<String, dynamic>.from(data));
      }
    });

    // 6. Message deleted (unsent)
    _socket!.on('message_deleted', (data) {
      if (data is Map) {
        _deleteController.add(Map<String, dynamic>.from(data));
      }
    });

    // 7. Typing status
    _socket!.on('user_typing', (data) {
      if (data is Map) {
        _typingController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('user_stop_typing', (data) {
      if (data is Map) {
        _stopTypingController.add(Map<String, dynamic>.from(data));
      }
    });

    // 8. Presence
    _socket!.on('user_online', (data) {
      if (data is Map) {
        _onlineController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('user_offline', (data) {
      if (data is Map) {
        _offlineController.add(Map<String, dynamic>.from(data));
      }
    });

    // 9. Clear Chat
    _socket!.on('chat_cleared', (data) {
      if (data is Map) {
        _chatClearedController.add(Map<String, dynamic>.from(data));
      }
    });

    // 10. Message request acceptance & decline
    _socket!.on('chat_request_accepted', (data) {
      if (data is Map) {
        _requestAcceptedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('chat_request_declined', (data) {
      if (data is Map) {
        _requestDeclinedController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // Room Join / Leave
  void joinChat(String chatId) {
    _socket?.emit('join_chat', chatId);
  }

  void leaveChat(String chatId) {
    _socket?.emit('leave_chat', chatId);
    _socket?.emit('stop_typing', {'chatId': chatId});
  }

  // Send Message
  void sendMessage({
    required String chatId,
    required String text,
    String? replyToId,
    String? sharedPostId,
    String? sharedStoryId,
    required Function(Map<String, dynamic>) onAck,
  }) {
    if (_socket == null || !_socket!.connected) return;

    final payload = {
      'chatId': chatId,
      'text': text,
      'replyToId': ?replyToId,
      'sharedPostId': ?sharedPostId,
      'sharedStoryId': ?sharedStoryId,
    };

    _socket!.emitWithAck(
      'send_message',
      payload,
      ack: (ack) {
        if (ack is Map) {
          onAck(Map<String, dynamic>.from(ack));
        }
      },
    );
  }

  // Mark as Read
  void markRead({required String chatId}) {
    _socket?.emit('mark_read', {'chatId': chatId});
  }

  // React to Message
  void reactMessage({required String messageId, required String emoji}) {
    _socket?.emit('react_message', {'messageId': messageId, 'emoji': emoji});
  }

  // Delete / Unsend Message
  void deleteMessage({required String messageId}) {
    _socket?.emit('delete_message', {'messageId': messageId});
  }

  // Typing Indicators
  void typing({required String chatId}) {
    _socket?.emit('typing', {'chatId': chatId});
  }

  void stopTyping({required String chatId}) {
    _socket?.emit('stop_typing', {'chatId': chatId});
  }

  // Presence Query On-Demand
  void getUserPresence({required String targetUserId, required Function(Map<String, dynamic>) onAck}) {
    if (_socket == null || !_socket!.connected) return;

    _socket!.emitWithAck(
      'get_user_presence',
      {'targetUserId': targetUserId},
      ack: (ack) {
        if (ack is Map) {
          onAck(Map<String, dynamic>.from(ack));
        }
      },
    );
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _newSentMessageController.close();
    _deliveredController.close();
    _readController.close();
    _reactionController.close();
    _deleteController.close();
    _typingController.close();
    _stopTypingController.close();
    _onlineController.close();
    _offlineController.close();
    _chatClearedController.close();
    _requestAcceptedController.close();
    _requestDeclinedController.close();
  }
}
