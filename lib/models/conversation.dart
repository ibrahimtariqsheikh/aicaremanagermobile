import 'package:aicaremanagermob/models/user.dart' as app_user;
import 'package:aicaremanagermob/models/message.dart';
import 'package:aicaremanagermob/models/conversation_participant.dart';
import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;
  final String senderId;
  final app_user.User? sender;
  final String receiverId;
  final app_user.User? receiver;
  final List<ConversationParticipant> participants;

  Conversation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    required this.senderId,
    this.sender,
    required this.receiverId,
    this.receiver,
    this.participants = const [],
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        messages,
        senderId,
        sender,
        receiverId,
        receiver,
        participants,
      ];

  @override
  bool get stringify => true;

  Conversation copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
    String? senderId,
    app_user.User? sender,
    String? receiverId,
    app_user.User? receiver,
    List<ConversationParticipant>? participants,
  }) {
    return Conversation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      receiverId: receiverId ?? this.receiverId,
      receiver: receiver ?? this.receiver,
      participants: participants ?? this.participants,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    print('Conversation JSON: $json'); // Debug print
    print('Messages in JSON: ${json['messages']}'); // Debug print for messages

    return Conversation(
      id: json['id'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      messages: json['messages'] != null
          ? (json['messages'] as List).map((m) {
              print('Processing message: $m'); // Debug print for each message
              return Message.fromJson(m as Map<String, dynamic>);
            }).toList()
          : [],
      senderId: json['senderId'] as String? ?? '',
      sender: json['sender'] != null
          ? app_user.User.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      receiverId: json['receiverId'] as String? ?? '',
      receiver: json['receiver'] != null
          ? app_user.User.fromJson(json['receiver'] as Map<String, dynamic>)
          : null,
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((p) =>
                  ConversationParticipant.fromJson(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'senderId': senderId,
      'sender': sender?.toJson(),
      'receiverId': receiverId,
      'receiver': receiver?.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Conversation(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, messages: $messages, senderId: $senderId, sender: $sender, receiverId: $receiverId, receiver: $receiver, participants: $participants)';
  }
}
