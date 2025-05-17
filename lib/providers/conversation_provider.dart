import 'package:aicaremanagermob/utils/toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aicaremanagermob/models/conversation.dart';
import 'package:aicaremanagermob/models/message.dart';
import 'package:aicaremanagermob/services/conversation_service.dart';
import 'package:aicaremanagermob/models/user.dart' as app_user;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_provider.freezed.dart';

@freezed
abstract class ConversationState with _$ConversationState {
  const factory ConversationState({
    Conversation? conversation,
    @Default(false) bool isLoading,
    String? error,
  }) = _ConversationState;
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  final ConversationService _conversationService;

  ConversationNotifier(this._conversationService)
      : super(const ConversationState());

  Future<void> loadConversations() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final conversations = await _conversationService.getUserConversations();
      if (conversations.isNotEmpty) {
        state = state.copyWith(
          conversation: conversations.first,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> getOrCreateConversation({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final conversation = await _conversationService.getOrCreateConversation(
        senderId: senderId,
        receiverId: receiverId,
      );

      state = state.copyWith(
        conversation: conversation,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _conversationService.markConversationAsRead(conversationId);

      // Update the conversation in the state if it matches
      if (state.conversation?.id == conversationId) {
        state = state.copyWith(
          conversation: state.conversation,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(
      Message message, String agencyId, String senderId) async {
    try {
      print('📤 [Provider] Sending message');
      print('📤 [Provider] Message content: ${message.content}');
      print('📤 [Provider] Conversation ID: ${message.conversationId}');
      print('📤 [Provider] Agency ID: $agencyId');
      print('📤 [Provider] Sender ID: $senderId');

      if (state.conversation == null) {
        throw Exception('No active conversation');
      }

      final response = await _conversationService.sendMessage(
        content: message.content,
        conversationId: state.conversation!.id,
        senderId: senderId,
        agencyId: agencyId,
      );

      print('📤 [Provider] Message sent successfully');
      print('📤 [Provider] Response message ID: ${response.id}');

      print('📤 [Provider] Conversation state updated');
    } catch (e) {
      print('❌ [Provider] Error sending message: $e');
      state = state.copyWith(error: e.toString());
      throw Exception('Failed to send message: $e');
    }
  }

  void updateConversation(Conversation updatedConversation) {
    state = state.copyWith(
      conversation: updatedConversation,
    );
  }

  Future<void> loadMoreMessages({
    required String conversationId,
    required int page,
    required int limit,
  }) async {
    try {
      final messages = await _conversationService.getMessages(
        conversationId: conversationId,
        page: page,
        limit: limit,
      );

      if (state.conversation != null) {
        final updatedMessages = [...state.conversation!.messages, ...messages];
        state = state.copyWith(
          conversation: state.conversation!.copyWith(
            messages: updatedMessages,
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier(ref.watch(conversationServiceProvider));
});
