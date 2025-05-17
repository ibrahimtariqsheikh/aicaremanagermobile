enum Role {
  SOFTWARE_OWNER,
  ADMIN,
  CARE_WORKER,
  OFFICE_STAFF,
  CLIENT,
  FAMILY,
}

class MessageData {
  final String username;
  final String message;
  final DateTime createdAt;
  final String senderID;
  final String receiverID;
  final String? urlAvatar;
  final DateTime? scheduleDate;
  final String? scheduleType;
  final Role role;
  final String? clientId;

  MessageData({
    required this.username,
    required this.message,
    required this.createdAt,
    required this.senderID,
    required this.receiverID,
    this.urlAvatar,
    this.scheduleDate,
    this.scheduleType,
    this.clientId,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'senderID': senderID,
      'receiverID': receiverID,
      'urlAvatar': urlAvatar,
      'scheduleDate': scheduleDate?.toIso8601String(),
      'scheduleType': scheduleType,
      'clientId': clientId,
      'role': role.name,
    };
  }

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      username: json['username'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      senderID: json['senderID'] as String,
      receiverID: json['receiverID'] as String,
      urlAvatar: json['urlAvatar'] as String?,
      scheduleDate: json['scheduleDate'] != null
          ? DateTime.parse(json['scheduleDate'] as String)
          : null,
      scheduleType: json['scheduleType'] as String?,
      clientId: json['clientId'] as String?,
      role: Role.values.byName(json['role'] as String),
    );
  }
}
