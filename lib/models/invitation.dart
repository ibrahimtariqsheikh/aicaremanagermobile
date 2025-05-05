enum InvitationStatus {
  pending,
  accepted,
  rejected,
  expired,
}

class Invitation {
  final String id;
  final String email;
  final String role;
  final String? subRole;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? agencyId;
  final String? invitedById;

  Invitation({
    required this.id,
    required this.email,
    required this.role,
    this.subRole,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.agencyId,
    this.invitedById,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      subRole: json['subRole'] as String?,
      status: InvitationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => InvitationStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      agencyId: json['agencyId'] as String?,
      invitedById: json['invitedById'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'subRole': subRole,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'agencyId': agencyId,
      'invitedById': invitedById,
    };
  }
} 