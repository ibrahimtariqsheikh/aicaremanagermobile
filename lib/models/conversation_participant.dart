import 'package:aicaremanagermob/models/user.dart' as app_user;
import 'package:aicaremanagermob/models/conversation.dart';

class ConversationParticipant {
  final String id;
  final String userId;
  final String conversationId;
  final DateTime joinedAt;
  final app_user.User? user;
  final Conversation? conversation;

  ConversationParticipant({
    required this.id,
    required this.userId,
    required this.conversationId,
    required this.joinedAt,
    this.user,
    this.conversation,
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: json['id'] as String,
      userId: json['userId'] as String,
      conversationId: json['conversationId'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      user: json['user'] != null
          ? app_user.User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      conversation: json['conversation'] != null
          ? Conversation.fromJson(json['conversation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'conversationId': conversationId,
      'joinedAt': joinedAt.toIso8601String(),
      'user': user?.toJson(),
      'conversation': conversation?.toJson(),
    };
  }
}
