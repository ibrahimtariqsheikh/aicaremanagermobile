import 'package:equatable/equatable.dart';

enum Role {
  softwareOwner,
  admin,
  careWorker,
  officeStaff,
  client,
  family,
}

enum SubRole {
  financeManager,
  hrManager,
  careManager,
  schedulingCoordinator,
  officeAdministrator,
  receptionist,
  qualityAssuranceManager,
  marketingCoordinator,
  complianceOfficer,
  caregiver,
  seniorCaregiver,
  juniorCaregiver,
  traineeCaregiver,
  liveInCaregiver,
  partTimeCaregiver,
  specializedCaregiver,
  nursingAssistant,
  serviceUser,
  familyAndFriends,
  other,
}

class User extends Equatable {
  final String id;
  final String cognitoId;
  final String email;
  final String fullName;
  final String? preferredName;
  final Role role;
  final SubRole? subRole;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? agencyId;
  final String? invitedById;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? propertyAccess;
  final String? phoneNumber;
  final String? nhsNumber;
  final bool? dnraOrder;
  final String? mobility;
  final String? likesDislikes;
  final DateTime? dateOfBirth;
  final String? languages;
  final String? allergies;
  final String? interests;
  final String? history;

  const User({
    required this.id,
    required this.cognitoId,
    required this.email,
    required this.fullName,
    this.preferredName,
    required this.role,
    this.subRole,
    required this.createdAt,
    required this.updatedAt,
    this.agencyId,
    this.invitedById,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.propertyAccess,
    this.phoneNumber,
    this.nhsNumber,
    this.dnraOrder,
    this.mobility,
    this.likesDislikes,
    this.dateOfBirth,
    this.languages,
    this.allergies,
    this.interests,
    this.history,
  });

  @override
  List<Object?> get props => [
    id,
    cognitoId,
    email,
    fullName,
    preferredName,
    role,
    subRole,
    createdAt,
    updatedAt,
    agencyId,
    invitedById,
    address,
    city,
    province,
    postalCode,
    propertyAccess,
    phoneNumber,
    nhsNumber,
    dnraOrder,
    mobility,
    likesDislikes,
    dateOfBirth,
    languages,
    allergies,
    interests,
    history,
  ];

  @override
  bool get stringify => true;

  User copyWith({
    String? id,
    String? cognitoId,
    String? email,
    String? fullName,
    String? preferredName,
    Role? role,
    SubRole? subRole,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? agencyId,
    String? invitedById,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? propertyAccess,
    String? phoneNumber,
    String? nhsNumber,
    bool? dnraOrder,
    String? mobility,
    String? likesDislikes,
    DateTime? dateOfBirth,
    String? languages,
    String? allergies,
    String? interests,
    String? history,
  }) {
    return User(
      id: id ?? this.id,
      cognitoId: cognitoId ?? this.cognitoId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      preferredName: preferredName ?? this.preferredName,
      role: role ?? this.role,
      subRole: subRole ?? this.subRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      agencyId: agencyId ?? this.agencyId,
      invitedById: invitedById ?? this.invitedById,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      propertyAccess: propertyAccess ?? this.propertyAccess,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nhsNumber: nhsNumber ?? this.nhsNumber,
      dnraOrder: dnraOrder ?? this.dnraOrder,
      mobility: mobility ?? this.mobility,
      likesDislikes: likesDislikes ?? this.likesDislikes,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      languages: languages ?? this.languages,
      allergies: allergies ?? this.allergies,
      interests: interests ?? this.interests,
      history: history ?? this.history,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role, subRole: $subRole)';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    
    final user = User(
      id: json['id'] as String,
      cognitoId: json['cognitoId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      preferredName: json['preferredName'] as String?,
      role: Role.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['role'],
        orElse: () => Role.client,
      ),
      subRole: json['subRole'] != null
          ? SubRole.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['subRole'],
              orElse: () => SubRole.other,
            )
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      agencyId: json['agencyId'] as String?,
      invitedById: json['invitedById'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      postalCode: json['postalCode'] as String?,
      propertyAccess: json['propertyAccess'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      nhsNumber: json['nhsNumber'] as String?,
      dnraOrder: json['dnraOrder'] as bool?,
      mobility: json['mobility'] as String?,
      likesDislikes: json['likesDislikes'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      languages: json['languages'] as String?,
      allergies: json['allergies'] as String?,
      interests: json['interests'] as String?,
      history: json['history'] as String?,
    );
    
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cognitoId': cognitoId,
      'email': email,
      'fullName': fullName,
      'preferredName': preferredName,
      'role': role.toString().split('.').last,
      'subRole': subRole?.toString().split('.').last,
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
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'languages': languages,
      'allergies': allergies,
      'interests': interests,
      'history': history,
    };
  }
} 