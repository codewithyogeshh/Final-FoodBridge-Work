enum UserRole {
  donor,
  ngo,
  volunteer,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.donor:
        return 'Donor';
      case UserRole.ngo:
        return 'NGO Shelter';
      case UserRole.volunteer:
        return 'Volunteer';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase().trim()) {
      case 'ngo':
        return UserRole.ngo;
      case 'volunteer':
        return UserRole.volunteer;
      case 'admin':
        return UserRole.admin;
      case 'donor':
      default:
        return UserRole.donor;
    }
  }
}

enum NgoVerificationStatus {
  unverified,
  pending,
  verified,
  rejected;

  String get displayName {
    switch (this) {
      case NgoVerificationStatus.unverified:
        return 'Unverified';
      case NgoVerificationStatus.pending:
        return 'Pending Verification';
      case NgoVerificationStatus.verified:
        return 'Verified 80G/Darpan';
      case NgoVerificationStatus.rejected:
        return 'Rejected';
    }
  }

  static NgoVerificationStatus fromString(String? status) {
    switch (status?.toLowerCase().trim()) {
      case 'pending':
        return NgoVerificationStatus.pending;
      case 'verified':
        return NgoVerificationStatus.verified;
      case 'rejected':
        return NgoVerificationStatus.rejected;
      case 'unverified':
      default:
        return NgoVerificationStatus.unverified;
    }
  }
}

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final NgoVerificationStatus ngoVerificationStatus;
  final String? organizationName;
  final String? darpanId;
  final String? registrationNumber;
  final String? contactPerson;
  final String? verificationDocumentUrl;
  final String? address;
  final String? serviceArea;
  final String? donorCategory;
  final String? availability;
  final String? transportType;
  final bool hasAcceptedTerms;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.ngoVerificationStatus = NgoVerificationStatus.unverified,
    this.organizationName,
    this.darpanId,
    this.registrationNumber,
    this.contactPerson,
    this.verificationDocumentUrl,
    this.address,
    this.serviceArea,
    this.donorCategory,
    this.availability,
    this.transportType,
    this.hasAcceptedTerms = false,
    required this.createdAt,
  });

  bool get isNgoVerified =>
      role == UserRole.ngo && ngoVerificationStatus == NgoVerificationStatus.verified;

  bool get isVolunteer => role == UserRole.volunteer;
  bool get isDonor => role == UserRole.donor;
  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'User',
      phone: json['phone'] as String?,
      role: UserRole.fromString(json['role'] as String?),
      ngoVerificationStatus: NgoVerificationStatus.fromString(
        json['ngo_verification_status'] as String?,
      ),
      organizationName: json['organization_name'] as String?,
      darpanId: json['darpan_id'] as String?,
      registrationNumber: json['registration_number'] as String?,
      contactPerson: json['contact_person'] as String?,
      verificationDocumentUrl: json['verification_document_url'] as String?,
      address: json['address'] as String?,
      serviceArea: json['service_area'] as String?,
      donorCategory: json['donor_category'] as String?,
      availability: json['availability'] as String?,
      transportType: json['transport_type'] as String?,
      hasAcceptedTerms: json['has_accepted_terms'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.name,
      'ngo_verification_status': ngoVerificationStatus.name,
      'organization_name': organizationName,
      'darpan_id': darpanId,
      'registration_number': registrationNumber,
      'contact_person': contactPerson,
      'verification_document_url': verificationDocumentUrl,
      'address': address,
      'service_area': serviceArea,
      'donor_category': donorCategory,
      'availability': availability,
      'transport_type': transportType,
      'has_accepted_terms': hasAcceptedTerms,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    NgoVerificationStatus? ngoVerificationStatus,
    String? organizationName,
    String? darpanId,
    String? registrationNumber,
    String? contactPerson,
    String? verificationDocumentUrl,
    String? address,
    String? serviceArea,
    String? donorCategory,
    String? availability,
    String? transportType,
    bool? hasAcceptedTerms,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      ngoVerificationStatus: ngoVerificationStatus ?? this.ngoVerificationStatus,
      organizationName: organizationName ?? this.organizationName,
      darpanId: darpanId ?? this.darpanId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      contactPerson: contactPerson ?? this.contactPerson,
      verificationDocumentUrl: verificationDocumentUrl ?? this.verificationDocumentUrl,
      address: address ?? this.address,
      serviceArea: serviceArea ?? this.serviceArea,
      donorCategory: donorCategory ?? this.donorCategory,
      availability: availability ?? this.availability,
      transportType: transportType ?? this.transportType,
      hasAcceptedTerms: hasAcceptedTerms ?? this.hasAcceptedTerms,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

