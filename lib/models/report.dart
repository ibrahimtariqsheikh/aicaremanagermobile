import 'package:aicaremanagermob/models/medication.dart';

class Report {
  final String id;
  final String clientId;
  final String agencyId;
  final String userId;
  final String? visitTypeId;
  final String? title;
  final String condition;
  final String summary;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final DateTime createdAt;
  final double? checkInDistance;
  final double? checkOutDistance;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? signatureImageUrl;
  final String status;
  final DateTime? lastEditedAt;
  final String? lastEditedBy;
  final String? lastEditReason;
  final ReportClient client;
  final ReportCaregiver caregiver;
  final ReportVisitType? visitType;
  final List<ReportTask>? tasksCompleted;
  final VisitSnapshot? visitSnapshot;
  final List<MedicationSnapshot> medicationSnapshot;

  Report({
    required this.id,
    required this.clientId,
    required this.agencyId,
    required this.userId,
    this.visitTypeId,
    this.title,
    required this.condition,
    required this.summary,
    required this.checkInTime,
    this.checkOutTime,
    required this.createdAt,
    this.checkInDistance,
    this.checkOutDistance,
    this.checkInLocation,
    this.checkOutLocation,
    this.signatureImageUrl,
    required this.status,
    this.lastEditedAt,
    this.lastEditedBy,
    this.lastEditReason,
    required this.client,
    required this.caregiver,
    this.visitType,
    this.tasksCompleted,
    this.visitSnapshot,
    required this.medicationSnapshot,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      agencyId: json['agencyId'] ?? '',
      userId: json['userId'] ?? '',
      visitTypeId: json['visitTypeId'],
      title: json['title'],
      condition: json['condition'] ?? '',
      summary: json['summary'] ?? '',
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : DateTime.now(),
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      checkInDistance: json['checkInDistance'] != null
          ? (json['checkInDistance'] is int
              ? (json['checkInDistance'] as int).toDouble()
              : json['checkInDistance'] as double)
          : null,
      checkOutDistance: json['checkOutDistance'] != null
          ? (json['checkOutDistance'] is int
              ? (json['checkOutDistance'] as int).toDouble()
              : json['checkOutDistance'] as double)
          : null,
      checkInLocation: json['checkInLocation'],
      checkOutLocation: json['checkOutLocation'],
      signatureImageUrl: json['signatureImageUrl'],
      status: json['status'] ?? 'PENDING',
      lastEditedAt: json['lastEditedAt'] != null
          ? DateTime.parse(json['lastEditedAt'])
          : null,
      lastEditedBy: json['lastEditedBy'],
      lastEditReason: json['lastEditReason'],
      client: json['client'] != null
          ? ReportClient.fromJson(json['client'])
          : ReportClient(
              id: '',
              cognitoId: '',
              email: '',
              fullName: 'Unknown Client',
              preferredName: '',
              role: 'CLIENT',
              subRole: 'SERVICE_USER',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              agencyId: '',
              address: '',
              city: '',
              province: '',
              postalCode: '',
              propertyAccess: '',
              phoneNumber: '',
              nhsNumber: '',
              dnraOrder: false,
              mobility: '',
              likesDislikes: '',
              dateOfBirth: DateTime.now(),
              languages: '',
              allergies: '',
              interests: '',
              history: '',
            ),
      caregiver: json['caregiver'] != null
          ? ReportCaregiver.fromJson(json['caregiver'])
          : ReportCaregiver(
              id: '',
              cognitoId: '',
              email: '',
              fullName: 'Unknown Caregiver',
              preferredName: '',
              role: 'CARE_WORKER',
              subRole: 'SENIOR_CAREGIVER',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              agencyId: '',
              address: '',
              city: '',
              province: '',
              postalCode: '',
              propertyAccess: '',
              phoneNumber: '',
              nhsNumber: '',
              dnraOrder: false,
              mobility: '',
              likesDislikes: '',
              dateOfBirth: DateTime.now(),
              languages: '',
              allergies: '',
              interests: '',
              history: '',
            ),
      visitType: json['visitType'] != null
          ? ReportVisitType.fromJson(json['visitType'])
          : null,
      tasksCompleted: json['tasksCompleted'] != null
          ? (json['tasksCompleted'] as List)
              .map((e) => ReportTask.fromJson(e))
              .toList()
          : null,
      visitSnapshot: json['visitSnapshot'] != null
          ? VisitSnapshot.fromJson(json['visitSnapshot'])
          : null,
      medicationSnapshot: json['medicationSnapshot'] != null
          ? (json['medicationSnapshot'] as List)
              .map((e) => MedicationSnapshot.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'agencyId': agencyId,
      'userId': userId,
      'visitTypeId': visitTypeId,
      'title': title,
      'condition': condition,
      'summary': summary,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'checkInDistance': checkInDistance,
      'checkOutDistance': checkOutDistance,
      'checkInLocation': checkInLocation,
      'checkOutLocation': checkOutLocation,
      'signatureImageUrl': signatureImageUrl,
      'status': status,
      'lastEditedAt': lastEditedAt?.toIso8601String(),
      'lastEditedBy': lastEditedBy,
      'lastEditReason': lastEditReason,
      'client': client.toJson(),
      'caregiver': caregiver.toJson(),
      'visitType': visitType?.toJson(),
      'tasksCompleted': tasksCompleted?.map((e) => e.toJson()).toList(),
      'visitSnapshot': visitSnapshot?.toJson(),
      'medicationSnapshot': medicationSnapshot.map((e) => e.toJson()).toList(),
    };
  }
}

class ReportClient {
  final String id;
  final String cognitoId;
  final String email;
  final String fullName;
  final String preferredName;
  final String role;
  final String subRole;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String agencyId;
  final String? invitedById;
  final String address;
  final String city;
  final String province;
  final String postalCode;
  final String propertyAccess;
  final String phoneNumber;
  final String nhsNumber;
  final bool dnraOrder;
  final String mobility;
  final String likesDislikes;
  final DateTime dateOfBirth;
  final String languages;
  final String allergies;
  final String interests;
  final String history;

  ReportClient({
    required this.id,
    required this.cognitoId,
    required this.email,
    required this.fullName,
    required this.preferredName,
    required this.role,
    required this.subRole,
    required this.createdAt,
    required this.updatedAt,
    required this.agencyId,
    this.invitedById,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.propertyAccess,
    required this.phoneNumber,
    required this.nhsNumber,
    required this.dnraOrder,
    required this.mobility,
    required this.likesDislikes,
    required this.dateOfBirth,
    required this.languages,
    required this.allergies,
    required this.interests,
    required this.history,
  });

  factory ReportClient.fromJson(Map<String, dynamic> json) {
    return ReportClient(
      id: json['id'] ?? '',
      cognitoId: json['cognitoId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? 'Unknown Client',
      preferredName: json['preferredName'] ?? '',
      role: json['role'] ?? 'CLIENT',
      subRole: json['subRole'] ?? 'SERVICE_USER',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      agencyId: json['agencyId'] ?? '',
      invitedById: json['invitedById'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      postalCode: json['postalCode'] ?? '',
      propertyAccess: json['propertyAccess'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      nhsNumber: json['nhsNumber'] ?? '',
      dnraOrder: json['dnraOrder'] ?? false,
      mobility: json['mobility'] ?? '',
      likesDislikes: json['likesDislikes'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : DateTime.now(),
      languages: json['languages'] ?? '',
      allergies: json['allergies'] ?? '',
      interests: json['interests'] ?? '',
      history: json['history'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cognitoId': cognitoId,
      'email': email,
      'fullName': fullName,
      'preferredName': preferredName,
      'role': role,
      'subRole': subRole,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'agencyId': agencyId,
      'invitedById': invitedById,
      'address': address,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'propertyAccess': propertyAccess,
      'phoneNumber': phoneNumber,
      'nhsNumber': nhsNumber,
      'dnraOrder': dnraOrder,
      'mobility': mobility,
      'likesDislikes': likesDislikes,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'languages': languages,
      'allergies': allergies,
      'interests': interests,
      'history': history,
    };
  }
}

class ReportCaregiver {
  final String id;
  final String cognitoId;
  final String email;
  final String fullName;
  final String preferredName;
  final String role;
  final String subRole;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String agencyId;
  final String? invitedById;
  final String address;
  final String city;
  final String province;
  final String postalCode;
  final String propertyAccess;
  final String phoneNumber;
  final String nhsNumber;
  final bool dnraOrder;
  final String mobility;
  final String likesDislikes;
  final DateTime dateOfBirth;
  final String languages;
  final String allergies;
  final String interests;
  final String history;

  ReportCaregiver({
    required this.id,
    required this.cognitoId,
    required this.email,
    required this.fullName,
    required this.preferredName,
    required this.role,
    required this.subRole,
    required this.createdAt,
    required this.updatedAt,
    required this.agencyId,
    this.invitedById,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.propertyAccess,
    required this.phoneNumber,
    required this.nhsNumber,
    required this.dnraOrder,
    required this.mobility,
    required this.likesDislikes,
    required this.dateOfBirth,
    required this.languages,
    required this.allergies,
    required this.interests,
    required this.history,
  });

  factory ReportCaregiver.fromJson(Map<String, dynamic> json) {
    return ReportCaregiver(
      id: json['id'] ?? '',
      cognitoId: json['cognitoId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? 'Unknown Caregiver',
      preferredName: json['preferredName'] ?? '',
      role: json['role'] ?? 'CARE_WORKER',
      subRole: json['subRole'] ?? 'SENIOR_CAREGIVER',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      agencyId: json['agencyId'] ?? '',
      invitedById: json['invitedById'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      postalCode: json['postalCode'] ?? '',
      propertyAccess: json['propertyAccess'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      nhsNumber: json['nhsNumber'] ?? '',
      dnraOrder: json['dnraOrder'] ?? false,
      mobility: json['mobility'] ?? '',
      likesDislikes: json['likesDislikes'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : DateTime.now(),
      languages: json['languages'] ?? '',
      allergies: json['allergies'] ?? '',
      interests: json['interests'] ?? '',
      history: json['history'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cognitoId': cognitoId,
      'email': email,
      'fullName': fullName,
      'preferredName': preferredName,
      'role': role,
      'subRole': subRole,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'agencyId': agencyId,
      'invitedById': invitedById,
      'address': address,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'propertyAccess': propertyAccess,
      'phoneNumber': phoneNumber,
      'nhsNumber': nhsNumber,
      'dnraOrder': dnraOrder,
      'mobility': mobility,
      'likesDislikes': likesDislikes,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'languages': languages,
      'allergies': allergies,
      'interests': interests,
      'history': history,
    };
  }
}

class ReportVisitType {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  ReportVisitType({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory ReportVisitType.fromJson(Map<String, dynamic> json) {
    return ReportVisitType(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userId: json['userId'],
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
    };
  }
}

class VisitSnapshot {
  final String id;
  final String reportId;
  final String visitTypeName;
  final String visitTypeDescription;
  final DateTime createdAt;
  final List<TaskSnapshot> taskSnapshots;

  VisitSnapshot({
    required this.id,
    required this.reportId,
    required this.visitTypeName,
    required this.visitTypeDescription,
    required this.createdAt,
    required this.taskSnapshots,
  });

  factory VisitSnapshot.fromJson(Map<String, dynamic> json) {
    return VisitSnapshot(
      id: json['id'],
      reportId: json['reportId'],
      visitTypeName: json['visitTypeName'] ?? '',
      visitTypeDescription: json['visitTypeDescription'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      taskSnapshots: (json['taskSnapshots'] as List)
          .map((e) => TaskSnapshot.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportId': reportId,
      'visitTypeName': visitTypeName,
      'visitTypeDescription': visitTypeDescription,
      'createdAt': createdAt.toIso8601String(),
      'taskSnapshots': taskSnapshots.map((e) => e.toJson()).toList(),
    };
  }
}

class TaskSnapshot {
  final String id;
  final String visitSnapshotId;
  final String? originalTaskId;
  final String taskType;
  final String taskName;
  final String careworkerNotes;

  TaskSnapshot({
    required this.id,
    required this.visitSnapshotId,
    this.originalTaskId,
    required this.taskType,
    required this.taskName,
    required this.careworkerNotes,
  });

  factory TaskSnapshot.fromJson(Map<String, dynamic> json) {
    return TaskSnapshot(
      id: json['id'],
      visitSnapshotId: json['visitSnapshotId'],
      originalTaskId: json['originalTaskId'],
      taskType: json['taskType'],
      taskName: json['taskName'] ?? '',
      careworkerNotes: json['careworkerNotes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitSnapshotId': visitSnapshotId,
      'originalTaskId': originalTaskId,
      'taskType': taskType,
      'taskName': taskName,
      'careworkerNotes': careworkerNotes,
    };
  }
}

class MedicationSnapshot {
  final String id;
  final String reportId;
  final String medicationId;
  final Medication medication;

  MedicationSnapshot({
    required this.id,
    required this.reportId,
    required this.medicationId,
    required this.medication,
  });

  factory MedicationSnapshot.fromJson(Map<String, dynamic> json) {
    return MedicationSnapshot(
      id: json['id'],
      reportId: json['reportId'],
      medicationId: json['medicationId'],
      medication: Medication.fromJson(json['medication']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportId': reportId,
      'medicationId': medicationId,
      'medication': medication.toJson(),
    };
  }
}

class ReportTask {
  final String id;
  final String reportId;
  final String? taskId;
  final String taskName;
  final bool completed;
  final String? notes;
  final String? taskIcon;
  final String? taskType;
  final DateTime? completedAt;

  ReportTask({
    required this.id,
    required this.reportId,
    this.taskId,
    required this.taskName,
    required this.completed,
    this.notes,
    this.taskIcon,
    this.taskType,
    this.completedAt,
  });

  factory ReportTask.fromJson(Map<String, dynamic> json) {
    return ReportTask(
      id: json['id'],
      reportId: json['reportId'],
      taskId: json['taskId'],
      taskName: json['taskName'] ?? '',
      completed: json['completed'] ?? false,
      notes: json['notes'],
      taskIcon: json['taskIcon'],
      taskType: json['taskType'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportId': reportId,
      'taskId': taskId,
      'taskName': taskName,
      'completed': completed,
      'notes': notes,
      'taskIcon': taskIcon,
      'taskType': taskType,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
