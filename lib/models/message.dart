import 'package:aicaremanagermob/models/user.dart' as app_user;
import 'package:aicaremanagermob/models/conversation.dart';
import 'package:aicaremanagermob/models/agency.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String content;
  final String senderId;
  final String conversationId;
  final DateTime sentAt;
  final DateTime updatedAt;
  final bool isRead;
  final bool isTyping;
  final app_user.User? sender;
  final Conversation? conversation;
  final String? agencyId;
  final Agency? agency;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.conversationId,
    required this.sentAt,
    required this.updatedAt,
    this.isRead = false,
    this.isTyping = false,
    this.sender,
    this.conversation,
    this.agencyId,
    this.agency,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        senderId,
        conversationId,
        sentAt,
        updatedAt,
        isRead,
        isTyping,
        sender,
        conversation,
        agencyId,
        agency,
        createdAt,
      ];

  Message copyWith({
    String? id,
    String? content,
    String? senderId,
    String? conversationId,
    DateTime? sentAt,
    DateTime? updatedAt,
    bool? isRead,
    bool? isTyping,
    app_user.User? sender,
    Conversation? conversation,
    String? agencyId,
    Agency? agency,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      conversationId: conversationId ?? this.conversationId,
      sentAt: sentAt ?? this.sentAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      isTyping: isTyping ?? this.isTyping,
      sender: sender ?? this.sender,
      conversation: conversation ?? this.conversation,
      agencyId: agencyId ?? this.agencyId,
      agency: agency ?? this.agency,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      conversationId: json['conversationId'] as String,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      isTyping: json['isTyping'] as bool? ?? false,
      sender: json['sender'] != null
          ? app_user.User.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      conversation: json['conversation'] != null
          ? Conversation.fromJson(json['conversation'] as Map<String, dynamic>)
          : null,
      agencyId: json['agencyId'] as String?,
      agency: json['agency'] != null
          ? Agency.fromJson(json['agency'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'conversationId': conversationId,
      'sentAt': sentAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRead': isRead,
      'isTyping': isTyping,
      'sender': sender?.toJson(),
      'conversation': conversation?.toJson(),
      'agencyId': agencyId,
      'agency': agency?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
