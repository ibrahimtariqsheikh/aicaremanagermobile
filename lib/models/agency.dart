import 'package:equatable/equatable.dart';

enum NotificationFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

enum PreferredNotificationMethod {
  email,
  sms,
  phone,
}

class Agency extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? description;
  final String? address;
  final String? extension;
  final String? mobileNumber;
  final String? landlineNumber;
  final String? website;
  final String? logo;
  final String? primaryColor;
  final String? secondaryColor;
  final bool isActive;
  final bool isSuspended;
  final bool hasScheduleV2;
  final bool hasEMAR;
  final bool hasFinance;
  final bool isWeek1And2ScheduleEnabled;
  final bool hasPoliciesAndProcedures;
  final bool isTestAccount;
  final bool allowCareWorkersEditCheckIn;
  final bool allowFamilyReviews;
  final bool enableFamilySchedule;
  final bool enableWeek1And2Scheduling;
  final String lateVisitThreshold;
  final bool enableDistanceAlerts;
  final String distanceThreshold;
  final bool lateVisitAlerts;
  final bool clientBirthdayReminders;
  final bool careWorkerVisitAlerts;
  final bool missedMedicationAlerts;
  final bool clientAndCareWorkerReminders;
  final bool distanceAlerts;
  final bool reviewNotifications;
  final PreferredNotificationMethod preferredNotificationMethod;
  final NotificationFrequency notificationFrequency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? licenseNumber;
  final String timeZone;
  final String currency;
  final int? maxUsers;
  final int? maxClients;
  final int? maxCareWorkers;
  final String? ownerId;

  const Agency({
    required this.id,
    required this.name,
    required this.email,
    this.description,
    this.address,
    this.extension,
    this.mobileNumber,
    this.landlineNumber,
    this.website,
    this.logo,
    this.primaryColor,
    this.secondaryColor,
    required this.isActive,
    required this.isSuspended,
    required this.hasScheduleV2,
    required this.hasEMAR,
    required this.hasFinance,
    required this.isWeek1And2ScheduleEnabled,
    required this.hasPoliciesAndProcedures,
    required this.isTestAccount,
    required this.allowCareWorkersEditCheckIn,
    required this.allowFamilyReviews,
    required this.enableFamilySchedule,
    required this.enableWeek1And2Scheduling,
    required this.lateVisitThreshold,
    required this.enableDistanceAlerts,
    required this.distanceThreshold,
    required this.lateVisitAlerts,
    required this.clientBirthdayReminders,
    required this.careWorkerVisitAlerts,
    required this.missedMedicationAlerts,
    required this.clientAndCareWorkerReminders,
    required this.distanceAlerts,
    required this.reviewNotifications,
    required this.preferredNotificationMethod,
    required this.notificationFrequency,
    required this.createdAt,
    required this.updatedAt,
    this.licenseNumber,
    required this.timeZone,
    required this.currency,
    this.maxUsers,
    this.maxClients,
    this.maxCareWorkers,
    this.ownerId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    description,
    address,
    extension,
    mobileNumber,
    landlineNumber,
    website,
    logo,
    primaryColor,
    secondaryColor,
    isActive,
    isSuspended,
    hasScheduleV2,
    hasEMAR,
    hasFinance,
    isWeek1And2ScheduleEnabled,
    hasPoliciesAndProcedures,
    isTestAccount,
    allowCareWorkersEditCheckIn,
    allowFamilyReviews,
    enableFamilySchedule,
    enableWeek1And2Scheduling,
    lateVisitThreshold,
    enableDistanceAlerts,
    distanceThreshold,
    lateVisitAlerts,
    clientBirthdayReminders,
    careWorkerVisitAlerts,
    missedMedicationAlerts,
    clientAndCareWorkerReminders,
    distanceAlerts,
    reviewNotifications,
    preferredNotificationMethod,
    notificationFrequency,
    createdAt,
    updatedAt,
    licenseNumber,
    timeZone,
    currency,
    maxUsers,
    maxClients,
    maxCareWorkers,
    ownerId,
  ];

  @override
  bool get stringify => true;

  Agency copyWith({
    String? id,
    String? name,
    String? email,
    String? description,
    String? address,
    String? extension,
    String? mobileNumber,
    String? landlineNumber,
    String? website,
    String? logo,
    String? primaryColor,
    String? secondaryColor,
    bool? isActive,
    bool? isSuspended,
    bool? hasScheduleV2,
    bool? hasEMAR,
    bool? hasFinance,
    bool? isWeek1And2ScheduleEnabled,
    bool? hasPoliciesAndProcedures,
    bool? isTestAccount,
    bool? allowCareWorkersEditCheckIn,
    bool? allowFamilyReviews,
    bool? enableFamilySchedule,
    bool? enableWeek1And2Scheduling,
    String? lateVisitThreshold,
    bool? enableDistanceAlerts,
    String? distanceThreshold,
    bool? lateVisitAlerts,
    bool? clientBirthdayReminders,
    bool? careWorkerVisitAlerts,
    bool? missedMedicationAlerts,
    bool? clientAndCareWorkerReminders,
    bool? distanceAlerts,
    bool? reviewNotifications,
    PreferredNotificationMethod? preferredNotificationMethod,
    NotificationFrequency? notificationFrequency,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? licenseNumber,
    String? timeZone,
    String? currency,
    int? maxUsers,
    int? maxClients,
    int? maxCareWorkers,
    String? ownerId,
  }) {
    return Agency(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      address: address ?? this.address,
      extension: extension ?? this.extension,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      landlineNumber: landlineNumber ?? this.landlineNumber,
      website: website ?? this.website,
      logo: logo ?? this.logo,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      isActive: isActive ?? this.isActive,
      isSuspended: isSuspended ?? this.isSuspended,
      hasScheduleV2: hasScheduleV2 ?? this.hasScheduleV2,
      hasEMAR: hasEMAR ?? this.hasEMAR,
      hasFinance: hasFinance ?? this.hasFinance,
      isWeek1And2ScheduleEnabled: isWeek1And2ScheduleEnabled ?? this.isWeek1And2ScheduleEnabled,
      hasPoliciesAndProcedures: hasPoliciesAndProcedures ?? this.hasPoliciesAndProcedures,
      isTestAccount: isTestAccount ?? this.isTestAccount,
      allowCareWorkersEditCheckIn: allowCareWorkersEditCheckIn ?? this.allowCareWorkersEditCheckIn,
      allowFamilyReviews: allowFamilyReviews ?? this.allowFamilyReviews,
      enableFamilySchedule: enableFamilySchedule ?? this.enableFamilySchedule,
      enableWeek1And2Scheduling: enableWeek1And2Scheduling ?? this.enableWeek1And2Scheduling,
      lateVisitThreshold: lateVisitThreshold ?? this.lateVisitThreshold,
      enableDistanceAlerts: enableDistanceAlerts ?? this.enableDistanceAlerts,
      distanceThreshold: distanceThreshold ?? this.distanceThreshold,
      lateVisitAlerts: lateVisitAlerts ?? this.lateVisitAlerts,
      clientBirthdayReminders: clientBirthdayReminders ?? this.clientBirthdayReminders,
      careWorkerVisitAlerts: careWorkerVisitAlerts ?? this.careWorkerVisitAlerts,
      missedMedicationAlerts: missedMedicationAlerts ?? this.missedMedicationAlerts,
      clientAndCareWorkerReminders: clientAndCareWorkerReminders ?? this.clientAndCareWorkerReminders,
      distanceAlerts: distanceAlerts ?? this.distanceAlerts,
      reviewNotifications: reviewNotifications ?? this.reviewNotifications,
      preferredNotificationMethod: preferredNotificationMethod ?? this.preferredNotificationMethod,
      notificationFrequency: notificationFrequency ?? this.notificationFrequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      timeZone: timeZone ?? this.timeZone,
      currency: currency ?? this.currency,
      maxUsers: maxUsers ?? this.maxUsers,
      maxClients: maxClients ?? this.maxClients,
      maxCareWorkers: maxCareWorkers ?? this.maxCareWorkers,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  String toString() {
    return 'Agency(id: $id, name: $name, email: $email, isActive: $isActive, timeZone: $timeZone)';
  }

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      extension: json['extension'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      landlineNumber: json['landlineNumber'] as String?,
      website: json['website'] as String?,
      logo: json['logo'] as String?,
      primaryColor: json['primaryColor'] as String?,
      secondaryColor: json['secondaryColor'] as String?,
      isActive: json['isActive'] as bool,
      isSuspended: json['isSuspended'] as bool,
      hasScheduleV2: json['hasScheduleV2'] as bool,
      hasEMAR: json['hasEMAR'] as bool,
      hasFinance: json['hasFinance'] as bool,
      isWeek1And2ScheduleEnabled: json['isWeek1And2ScheduleEnabled'] as bool,
      hasPoliciesAndProcedures: json['hasPoliciesAndProcedures'] as bool,
      isTestAccount: json['isTestAccount'] as bool,
      allowCareWorkersEditCheckIn: json['allowCareWorkersEditCheckIn'] as bool,
      allowFamilyReviews: json['allowFamilyReviews'] as bool,
      enableFamilySchedule: json['enableFamilySchedule'] as bool,
      enableWeek1And2Scheduling: json['enableWeek1And2Scheduling'] as bool,
      lateVisitThreshold: json['lateVisitThreshold'] as String,
      enableDistanceAlerts: json['enableDistanceAlerts'] as bool,
      distanceThreshold: json['distanceThreshold'] as String,
      lateVisitAlerts: json['lateVisitAlerts'] as bool,
      clientBirthdayReminders: json['clientBirthdayReminders'] as bool,
      careWorkerVisitAlerts: json['careWorkerVisitAlerts'] as bool,
      missedMedicationAlerts: json['missedMedicationAlerts'] as bool,
      clientAndCareWorkerReminders: json['clientAndCareWorkerReminders'] as bool,
      distanceAlerts: json['distanceAlerts'] as bool,
      reviewNotifications: json['reviewNotifications'] as bool,
      preferredNotificationMethod: PreferredNotificationMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['preferredNotificationMethod'],
        orElse: () => PreferredNotificationMethod.email,
      ),
      notificationFrequency: NotificationFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == json['notificationFrequency'],
        orElse: () => NotificationFrequency.daily,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      licenseNumber: json['licenseNumber'] as String?,
      timeZone: json['timeZone'] as String,
      currency: json['currency'] as String,
      maxUsers: json['maxUsers'] as int?,
      maxClients: json['maxClients'] as int?,
      maxCareWorkers: json['maxCareWorkers'] as int?,
      ownerId: json['ownerId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'description': description,
      'address': address,
      'extension': extension,
      'mobileNumber': mobileNumber,
      'landlineNumber': landlineNumber,
      'website': website,
      'logo': logo,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'isActive': isActive,
      'isSuspended': isSuspended,
      'hasScheduleV2': hasScheduleV2,
      'hasEMAR': hasEMAR,
      'hasFinance': hasFinance,
      'isWeek1And2ScheduleEnabled': isWeek1And2ScheduleEnabled,
      'hasPoliciesAndProcedures': hasPoliciesAndProcedures,
      'isTestAccount': isTestAccount,
      'allowCareWorkersEditCheckIn': allowCareWorkersEditCheckIn,
      'allowFamilyReviews': allowFamilyReviews,
      'enableFamilySchedule': enableFamilySchedule,
      'enableWeek1And2Scheduling': enableWeek1And2Scheduling,
      'lateVisitThreshold': lateVisitThreshold,
      'enableDistanceAlerts': enableDistanceAlerts,
      'distanceThreshold': distanceThreshold,
      'lateVisitAlerts': lateVisitAlerts,
      'clientBirthdayReminders': clientBirthdayReminders,
      'careWorkerVisitAlerts': careWorkerVisitAlerts,
      'missedMedicationAlerts': missedMedicationAlerts,
      'clientAndCareWorkerReminders': clientAndCareWorkerReminders,
      'distanceAlerts': distanceAlerts,
      'reviewNotifications': reviewNotifications,
      'preferredNotificationMethod': preferredNotificationMethod.toString().split('.').last,
      'notificationFrequency': notificationFrequency.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'licenseNumber': licenseNumber,
      'timeZone': timeZone,
      'currency': currency,
      'maxUsers': maxUsers,
      'maxClients': maxClients,
      'maxCareWorkers': maxCareWorkers,
      'ownerId': ownerId,
    };
  }
} 