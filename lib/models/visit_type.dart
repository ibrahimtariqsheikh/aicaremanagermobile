// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';
import 'medication.dart';

// Define task types as enum
enum TaskType {
  MEDICATION,
  BODYMAP,
  FOOD,
  DRINKS,
  PERSONALCARE,
  HYGIENE,
  TOILET_ASSISTANCE,
  REPOSITIONING,
  COMPANIONSHIP,
  LAUNDRY,
  GROCERIES,
  HOUSEWORK,
  CHORES,
  INCIDENT_RESPONSE,
  FIRE_SAFETY,
  BLOOD_PRESSURE,
  VITALS,
  OTHER;

  static TaskType fromString(String value) {
    return TaskType.values.firstWhere(
      (type) => type.toString().split('.').last.toUpperCase() == value,
      orElse: () => TaskType.OTHER,
    );
  }

  String toApiString() {
    return toString().split('.').last.toUpperCase();
  }
}

// Define AssignedTask class
class AssignedTask extends Equatable {
  final String id;
  final TaskType type;
  final String? careworkerNotes;
  final String visitTypeId;

  const AssignedTask({
    required this.id,
    required this.type,
    this.careworkerNotes,
    required this.visitTypeId,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        careworkerNotes,
        visitTypeId,
      ];

  factory AssignedTask.fromJson(Map<String, dynamic> json) {
    return AssignedTask(
      id: json['id'] as String,
      type: TaskType.fromString(json['type'] as String),
      careworkerNotes: json['careworkerNotes'] as String?,
      visitTypeId: json['visitTypeId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toApiString(),
      'careworkerNotes': careworkerNotes,
      'visitTypeId': visitTypeId,
    };
  }

  AssignedTask copyWith({
    String? id,
    TaskType? type,
    String? careworkerNotes,
    String? visitTypeId,
  }) {
    return AssignedTask(
      id: id ?? this.id,
      type: type ?? this.type,
      careworkerNotes: careworkerNotes ?? this.careworkerNotes,
      visitTypeId: visitTypeId ?? this.visitTypeId,
    );
  }
}

class VisitType extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final List<Medication>? medications;
  final List<AssignedTask>? assignedTasks;

  const VisitType({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.medications,
    this.assignedTasks,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        createdAt,
        updatedAt,
        userId,
        medications,
        assignedTasks,
      ];

  factory VisitType.fromJson(Map<String, dynamic> json) {
    List<Medication>? medicationsList;
    if (json['medications'] != null) {
      medicationsList = (json['medications'] as List)
          .map((item) => Medication.fromJson(item))
          .toList();
    }

    List<AssignedTask>? assignedTasksList;
    if (json['assignedTasks'] != null) {
      assignedTasksList = (json['assignedTasks'] as List)
          .map((item) => AssignedTask.fromJson(item))
          .toList();
    }

    return VisitType(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
      medications: medicationsList,
      assignedTasks: assignedTasksList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'medications': medications?.map((m) => m.toJson()).toList(),
      'assignedTasks': assignedTasks?.map((t) => t.toJson()).toList(),
    };
  }

  VisitType copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    List<Medication>? medications,
    List<AssignedTask>? assignedTasks,
  }) {
    return VisitType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      medications: medications ?? this.medications,
      assignedTasks: assignedTasks ?? this.assignedTasks,
    );
  }
}
