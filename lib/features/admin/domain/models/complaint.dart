enum ComplaintStatus {
  open,
  investigating,
  resolved,
  dismissed;

  String get displayName {
    switch (this) {
      case ComplaintStatus.open:
        return 'Open';
      case ComplaintStatus.investigating:
        return 'Under Investigation';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.dismissed:
        return 'Dismissed';
    }
  }
}

class Complaint {
  final String id;
  final String reporterName;
  final String reporterRole;
  final String respondentName;
  final String? donationId;
  final String category; // 'Quality / Hygiene', 'No-show / Delay', 'Address Misrepresentation', 'Misconduct'
  final String description;
  final ComplaintStatus status;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const Complaint({
    required this.id,
    required this.reporterName,
    required this.reporterRole,
    required this.respondentName,
    this.donationId,
    required this.category,
    required this.description,
    this.status = ComplaintStatus.open,
    this.resolutionNotes,
    required this.createdAt,
    this.resolvedAt,
  });

  Complaint copyWith({
    String? id,
    String? reporterName,
    String? reporterRole,
    String? respondentName,
    String? donationId,
    String? category,
    String? description,
    ComplaintStatus? status,
    String? resolutionNotes,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return Complaint(
      id: id ?? this.id,
      reporterName: reporterName ?? this.reporterName,
      reporterRole: reporterRole ?? this.reporterRole,
      respondentName: respondentName ?? this.respondentName,
      donationId: donationId ?? this.donationId,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as String,
      reporterName: json['reporter_name'] as String,
      reporterRole: json['reporter_role'] as String,
      respondentName: json['respondent_name'] as String,
      donationId: json['donation_id'] as String?,
      category: json['category'] as String,
      description: json['description'] as String,
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ComplaintStatus.open,
      ),
      resolutionNotes: json['resolution_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_name': reporterName,
      'reporter_role': reporterRole,
      'respondent_name': respondentName,
      'donation_id': donationId,
      'category': category,
      'description': description,
      'status': status.name,
      'resolution_notes': resolutionNotes,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}

