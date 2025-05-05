import 'package:equatable/equatable.dart';
import 'user.dart';

enum ScheduleType {
  weeklyCheckup,
  appointment,
  homeVisit,
  checkup,
  emergency,
  routine,
  other;

  static ScheduleType fromString(String value) {
    return ScheduleType.values.firstWhere(
      (type) => type.toString().split('.').last.toUpperCase() == value,
      orElse: () => ScheduleType.other,
    );
  }

  String toApiString() {
    return toString().split('.').last.toUpperCase();
  }
}

class Schedule extends Equatable {
  final String id;
  final String agencyId;
  final String clientId;
  final String userId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final ScheduleType type;
  final String? notes;
  final double? chargeRate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? visitTypeId;
  final User? client;

  const Schedule({
    required this.id,
    required this.agencyId,
    required this.clientId,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.type,
    this.notes,
    this.chargeRate,
    required this.createdAt,
    required this.updatedAt,
    this.visitTypeId,
    this.client,
  });

  @override
  List<Object?> get props => [
        id,
        agencyId,
        clientId,
        userId,
        date,
        startTime,
        endTime,
        status,
        type,
        notes,
        chargeRate,
        createdAt,
        updatedAt,
        visitTypeId,
        client,
      ];

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      agencyId: json['agencyId'] as String,
      clientId: json['clientId'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String,
      type: ScheduleType.fromString(json['type'] as String),
      notes: json['notes'] as String?,
      chargeRate: json['chargeRate'] != null
          ? (json['chargeRate'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      visitTypeId: json['visitTypeId'] as String?,
      client: json['client'] != null ? User.fromJson(json['client']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agencyId': agencyId,
      'clientId': clientId,
      'userId': userId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'type': type.toApiString(),
      'notes': notes,
      'chargeRate': chargeRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'visitTypeId': visitTypeId,
      'client': client?.toJson(),
    };
  }

  Schedule copyWith({
    String? id,
    String? agencyId,
    String? clientId,
    String? userId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? status,
    ScheduleType? type,
    String? notes,
    double? chargeRate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? visitTypeId,
    User? client,
  }) {
    return Schedule(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      chargeRate: chargeRate ?? this.chargeRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      visitTypeId: visitTypeId ?? this.visitTypeId,
      client: client ?? this.client,
    );
  }
} 