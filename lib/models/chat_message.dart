class ChatMessage {
  final String id;
  final String text;
  final DateTime createdAt;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;

  ChatMessage({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String?,
      senderAvatar: json['senderAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
    };
  }
} 