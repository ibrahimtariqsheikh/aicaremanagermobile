import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/configs/app_api_config.dart';
import 'package:aicaremanagermob/models/conversation.dart';
import 'package:aicaremanagermob/models/message.dart';
import 'package:aicaremanagermob/utils/toast.dart';

final conversationServiceProvider = Provider<ConversationService>((ref) {
  return ConversationService();
});

class ConversationService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  String _handleDioError(DioException error) {
    if (error.response != null) {
      // Server responded with an error
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (statusCode == 400) {
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return 'Invalid request. Please check your input data.';
      } else if (statusCode == 401) {
        return 'Unauthorized. Please login again.';
      } else if (statusCode == 403) {
        return 'Access denied. You don\'t have permission to perform this action.';
      } else if (statusCode == 404) {
        return 'Resource not found.';
      } else if (statusCode == 500) {
        return 'Server error. Please try again later.';
      }
      return 'Error: ${data ?? error.message}';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network settings.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  // Get all conversations for a user
  Future<List<Conversation>> getUserConversations() async {
    try {
      final response = await _dio.get('/api/messages/conversations');
      return (response.data['conversations'] as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } on DioException catch (error) {
      throw Exception(_handleDioError(error));
    } catch (error) {
      throw Exception('Failed to fetch conversations: $error');
    }
  }

  // Get or create a conversation with a user
  Future<Conversation> getOrCreateConversation({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final response = await _dio.post(
        '/messages/conversation',
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
        },
      );

      return Conversation.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // If conversation doesn't exist, create a new one
        return createConversation(
          senderId: senderId,
          receiverId: receiverId,
        );
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Failed to get or create conversation: $e');
    }
  }

  // Create a new conversation
  Future<Conversation> createConversation({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final response = await _dio.post(
        '/conversations/create',
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
        },
      );

      return Conversation.fromJson(response.data);
    } on DioException catch (error) {
      throw Exception(_handleDioError(error));
    } catch (error) {
      throw Exception('Failed to create conversation: $error');
    }
  }

  // Get conversation messages
  Future<List<Message>> getConversationMessages({
    required String conversationId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/messages/conversation/$conversationId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return (response.data as List)
          .map((json) => Message.fromJson(json))
          .toList();
    } on DioException catch (error) {
      throw Exception(_handleDioError(error));
    } catch (error) {
      throw Exception('Failed to fetch messages: $error');
    }
  }

  // Send a message in a conversation
  Future<Message> sendMessage({
    required String content,
    required String conversationId,
    required String senderId,
    required String agencyId,
  }) async {
    try {
      print('📤 [API] Sending message');
      print('📤 [API] Content: $content');
      print('📤 [API] Conversation ID: $conversationId');
      print('📤 [API] Sender ID: $senderId');
      print('📤 [API] Agency ID: $agencyId');

      final response = await _dio.post(
        '/messages',
        data: {
          'content': content,
          'conversationId': conversationId,
          'senderId': senderId,
          'agencyId': agencyId,
        },
      );

      print('📤 [API] Response status: ${response.statusCode}');
      print('📤 [API] Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Failed to send message: No response data');
      }

      // Create a message object from the response data
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        senderId: senderId,
        conversationId: conversationId,
        sentAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
        agencyId: agencyId,
      );

      print('📤 [API] Created message object: ${message.toJson()}');
      return message;
    } on DioException catch (error) {
      print('❌ [API] Dio error: ${error.message}');
      print('❌ [API] Error response: ${error.response?.data}');
      throw Exception(_handleDioError(error));
    } catch (error) {
      print('❌ [API] Error: $error');
      throw Exception('Failed to send message: $error');
    }
  }

  // Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _dio.post('/messages/conversation/read', data: {
        'conversationId': conversationId,
        'userId': 'current_user', // This should be replaced with actual user ID
      });
    } on DioException catch (error) {
      throw Exception(_handleDioError(error));
    } catch (error) {
      throw Exception('Failed to mark conversation as read: $error');
    }
  }

  // Set typing status
  Future<void> setTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await _dio.post('/messages/conversation/typing', data: {
        'conversationId': conversationId,
        'userId': userId,
        'isTyping': isTyping,
      });
    } on DioException catch (error) {
      throw Exception(_handleDioError(error));
    } catch (error) {
      throw Exception('Failed to set typing status: $error');
    }
  }

  // Update a message
  Future<Message> updateMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final response = await _dio.put(
        '/messages/$messageId',
        data: {
          'content': content,
        },
      );

      return Message.fromJson(response.data);
    } on DioException catch (error) {
      throw Exception(_handleDioError(error));
    } catch (error) {
      throw Exception('Failed to update message: $error');
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _dio.delete('/messages/$messageId');
    } on DioException catch (error) {
      throw Exception(_handleDioError(error));
    } catch (error) {
      throw Exception('Failed to delete message: $error');
    }
  }

  Future<List<Message>> getMessages({
    required String conversationId,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        '/messages/conversation/$conversationId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return (response.data as List)
          .map((json) => Message.fromJson(json))
          .toList();
    } on DioException catch (error) {
      throw Exception(_handleDioError(error));
    } catch (error) {
      throw Exception('Failed to fetch messages: $error');
    }
  }
}
