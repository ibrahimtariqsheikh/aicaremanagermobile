import 'package:aicaremanagermob/utils/toast.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/configs/app_api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService.getInstance();
});

class SocketService {
  late io.Socket _socket;
  bool _isConnected = false;
  late SharedPreferences _prefs;
  static const String _messageQueueKey = 'message_queue';
  static const String _lastMessageIdKey = 'last_message_id';
  final _messageController = StreamController<dynamic>.broadcast();
  String? _token;

  Stream<dynamic> get messageStream => _messageController.stream;

  static SocketService? _instance;

  SocketService._() {
    _initPrefs();
    _initializeSocket();
  }

  static SocketService getInstance() {
    _instance ??= SocketService._();
    return _instance!;
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _initializeSocket() {
    _socket = io.io(
      AppApiConfig.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders(
              _token != null ? {'Authorization': 'Bearer $_token'} : {})
          .build(),
    );

    _socket.onConnect((_) {
      _isConnected = true;
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
    });

    _socket.onError((error) {
      _isConnected = false;
    });

    _socket.onConnectError((error) {
      _isConnected = false;
    });

    _socket.onAny((event, data) {
      if (data is List && data.isNotEmpty) {
        final typingData = data[0];
        final userId = data.length > 1 ? data[1] : null;

        _messageController.add({
          'type': 'typing',
          'data': typingData,
          'userId': userId,
        });
      }
    });

    _socket.on('receive_message', (data) {
      print('📝 [Socket] Received message: $data');
      _messageController.add(data);
    });

    _socket.on('message', (data) {
      _messageController.add(data);
    });

    _socket.on('new_message', (data) {
      _messageController.add(data);
    });

    _socket.on('user_typing', (data) {
      print('📝 [Socket] Received typing event: $data');
      if (data is List && data.isNotEmpty) {
        final typingData = data[0];
        final userId = data.length > 1 ? data[1] : null;

        print('📝 [Socket] Processing typing event: $data');

        _messageController.add({
          'type': 'typing',
          'data': typingData,
          'userId': userId,
        });
      }
    });
  }

  Future<void> _handleSocketError(dynamic error) async {
    final prefs = await _prefs;
    final errors = prefs.getStringList('socket_errors') ?? [];
    errors.add('${DateTime.now().toIso8601String()}: $error');
    await prefs.setStringList('socket_errors', errors);
  }

  Future<void> _processMessageQueue() async {
    final prefs = await _prefs;
    final queue = prefs.getStringList(_messageQueueKey) ?? [];

    if (queue.isNotEmpty) {
      for (final message in queue) {
        try {
          final data = json.decode(message);
          _socket.emit('send_message', data);
        } catch (e) {
          // Error processing queued message
        }
      }
      await prefs.setStringList(_messageQueueKey, []);
    }
  }

  Future<void> connect(String userId) async {
    await _initPrefs();
    _token = _prefs.getString('token');
    _initializeSocket();
    _socket.connect();
  }

  void disconnect() {
    if (_isConnected) {
      _socket.disconnect();
      _isConnected = false;
    }
  }

  void joinRoom(String roomId) {
    if (!_isConnected) {
      return;
    }
    _socket.emit('join_room', {'roomId': roomId});
  }

  void leaveRoom(String roomId) {
    _socket.emit('leave_room', roomId);
  }

  Future<void> sendMessage({
    required String content,
    required String roomId,
    required String senderId,
  }) async {
    if (!_isConnected) {
      throw Exception('Socket not connected');
    }

    if (content.isEmpty) {
      throw Exception('Message content cannot be empty');
    }

    try {
      _socket.emit('send_message', {
        'content': content,
        'roomId': roomId,
        'senderId': senderId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  void onMessage(Function(dynamic) callback) {
    _socket.off('receive_message');
    _socket.off('message');
    _socket.off('new_message');

    _socket.on('receive_message', (data) {
      _handleReceivedMessage(data, callback);
    });

    _socket.on('message', (data) {
      _handleReceivedMessage(data, callback);
    });

    _socket.on('new_message', (data) {
      _handleReceivedMessage(data, callback);
    });
  }

  void _handleReceivedMessage(dynamic data, Function(dynamic) callback) {
    if (data == null) {
      return;
    }

    try {
      final message = {
        'id': data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'content': data['content'] ?? '',
        'senderId': data['senderId'] ?? '',
        'conversationId': data['conversationId'] ?? '',
        'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'sentAt': data['sentAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': data['updatedAt'] ?? DateTime.now().toIso8601String(),
      };
      callback(message);
    } catch (e) {
      // Error processing received message
    }
  }

  void onTyping(Function(dynamic) callback) {
    _socket.off('user_typing');

    _socket.on('user_typing', (data) {
      if (data is List && data.isNotEmpty) {
        final typingData = data[0];
        final userId = data.length > 1 ? data[1] : null;

        _messageController.add({
          'type': 'typing',
          'data': typingData,
          'userId': userId,
        });

        callback(data);
      }
    });
  }

  void onMessagesRead(Function(dynamic) callback) {
    _socket.on('messages_read', callback);
  }

  void onMessageDeleted(Function(dynamic) callback) {
    _socket.on('message_deleted', callback);
  }

  void onMessageUpdated(Function(dynamic) callback) {
    _socket.on('message_updated', callback);
  }

  void sendTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) {
    if (!_isConnected) {
      return;
    }

    try {
      _socket.emit('typing', {
        'conversationId': conversationId,
        'userId': userId,
        'isTyping': isTyping,
      });
    } catch (e) {
      // Error sending typing status
    }
  }

  void markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) {
    _socket.emit('mark_read', {
      'conversationId': conversationId,
      'userId': userId,
    });
  }

  Future<String?> getLastMessageId(String conversationId) async {
    final prefs = await _prefs;
    return prefs.getString('${_lastMessageIdKey}_$conversationId');
  }

  Future<void> setLastMessageId(String conversationId, String messageId) async {
    final prefs = await _prefs;
    await prefs.setString('${_lastMessageIdKey}_$conversationId', messageId);
  }

  void dispose() {
    _messageController.close();
    _socket.off('receive_message');
    _socket.off('user_typing');
    _socket.off('messages_read');
    _socket.off('message_deleted');
    _socket.off('message_updated');
    _socket.disconnect();
  }
}
