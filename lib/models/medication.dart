import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String? instructions;
  final bool morning;
  final bool afternoon;
  final bool evening;
  final bool bedtime;
  final bool asNeeded;
  final String userId;
  final String? visitTypeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.instructions,
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.bedtime,
    required this.asNeeded,
    required this.userId,
    this.visitTypeId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        dosage,
        frequency,
        instructions,
        morning,
        afternoon,
        evening,
        bedtime,
        asNeeded,
        userId,
        visitTypeId,
        createdAt,
        updatedAt,
      ];

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      instructions: json['instructions'] as String?,
      morning: json['morning'] as bool? ?? false,
      afternoon: json['afternoon'] as bool? ?? false,
      evening: json['evening'] as bool? ?? false,
      bedtime: json['bedtime'] as bool? ?? false,
      asNeeded: json['asNeeded'] as bool? ?? false,
      userId: json['userId'] as String,
      visitTypeId: json['visitTypeId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
      'bedtime': bedtime,
      'asNeeded': asNeeded,
      'userId': userId,
      'visitTypeId': visitTypeId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? instructions,
    bool? morning,
    bool? afternoon,
    bool? evening,
    bool? bedtime,
    bool? asNeeded,
    String? userId,
    String? visitTypeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      instructions: instructions ?? this.instructions,
      morning: morning ?? this.morning,
      afternoon: afternoon ?? this.afternoon,
      evening: evening ?? this.evening,
      bedtime: bedtime ?? this.bedtime,
      asNeeded: asNeeded ?? this.asNeeded,
      userId: userId ?? this.userId,
      visitTypeId: visitTypeId ?? this.visitTypeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
