class DistributionRecord {
  final String id;
  final String donationId;
  final String donationTitle;
  final String ngoId;
  final String ngoName;
  final String beneficiaryGroup;
  final int headcountServed;
  final double quantityDistributed;
  final String unit;
  final DateTime distributionDate;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;

  const DistributionRecord({
    required this.id,
    required this.donationId,
    required this.donationTitle,
    required this.ngoId,
    required this.ngoName,
    required this.beneficiaryGroup,
    required this.headcountServed,
    required this.quantityDistributed,
    required this.unit,
    required this.distributionDate,
    this.notes,
    this.photoUrl,
    required this.createdAt,
  });

  factory DistributionRecord.fromJson(Map<String, dynamic> json) {
    return DistributionRecord(
      id: json['id'] as String,
      donationId: json['donation_id'] as String,
      donationTitle: json['donation_title'] as String? ?? 'Donation',
      ngoId: json['ngo_id'] as String,
      ngoName: json['ngo_name'] as String? ?? 'NGO Shelter',
      beneficiaryGroup: json['beneficiary_group'] as String? ?? 'Community Shelter',
      headcountServed: json['headcount_served'] as int? ?? 1,
      quantityDistributed: (json['quantity_distributed'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? 'items',
      distributionDate: json['distribution_date'] != null
          ? DateTime.tryParse(json['distribution_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donation_id': donationId,
      'donation_title': donationTitle,
      'ngo_id': ngoId,
      'ngo_name': ngoName,
      'beneficiary_group': beneficiaryGroup,
      'headcount_served': headcountServed,
      'quantity_distributed': quantityDistributed,
      'unit': unit,
      'distribution_date': distributionDate.toIso8601String(),
      'notes': notes,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
