enum DonationType {
  food,
  clothing;

  String get displayName {
    switch (this) {
      case DonationType.food:
        return 'Food';
      case DonationType.clothing:
        return 'Clothing';
    }
  }

  static DonationType fromString(String? type) {
    switch (type?.toLowerCase().trim()) {
      case 'clothing':
      case 'cloth':
        return DonationType.clothing;
      case 'food':
      default:
        return DonationType.food;
    }
  }
}

enum DonationStatus {
  listed,
  claimed,
  assigned,
  pickedUp,
  delivered,
  cancelled,
  expired;

  String get displayName {
    switch (this) {
      case DonationStatus.listed:
        return 'Available';
      case DonationStatus.claimed:
        return 'Claimed by NGO';
      case DonationStatus.assigned:
        return 'Volunteer Assigned';
      case DonationStatus.pickedUp:
        return 'In Transit';
      case DonationStatus.delivered:
        return 'Delivered';
      case DonationStatus.cancelled:
        return 'Cancelled';
      case DonationStatus.expired:
        return 'Expired';
    }
  }

  static DonationStatus fromString(String? status) {
    switch (status?.toLowerCase().trim()) {
      case 'claimed':
        return DonationStatus.claimed;
      case 'assigned':
        return DonationStatus.assigned;
      case 'pickedup':
      case 'picked_up':
      case 'intransit':
      case 'in_transit':
        return DonationStatus.pickedUp;
      case 'delivered':
        return DonationStatus.delivered;
      case 'cancelled':
        return DonationStatus.cancelled;
      case 'expired':
        return DonationStatus.expired;
      case 'listed':
      default:
        return DonationStatus.listed;
    }
  }
}

class Donation {
  final String id;
  final String donorId;
  final String donorName;
  final String? donorPhone;
  final String title;
  final String description;
  final double quantity;
  final String unit; // 'meals', 'kg', 'boxes', 'pieces'
  final DonationType type;
  final DonationStatus status;
  final String pickupAddress;
  final String city;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime pickupDeadline;

  // NGO & Volunteer claim tracking
  final String? claimedByNgoId;
  final String? claimedByNgoName;
  final String? assignedVolunteerId;
  final String? assignedVolunteerName;
  final String? assignedVolunteerPhone;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? imageUrl;

  // Food specific attributes
  final bool isVeg;
  final DateTime? prepTime;
  final String? storageCondition; // 'ambient', 'chilled', 'hot'
  final String? allergenNotes;
  final bool safetyCharterAgreed;

  // Clothing specific attributes
  final String? clothingCategory; // 'kids', 'adults', 'winter', 'blankets'
  final String? conditionGrade; // 'brand_new', 'like_new', 'good'
  final bool isWashedAndClean;

  const Donation({
    required this.id,
    required this.donorId,
    required this.donorName,
    this.donorPhone,
    required this.title,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.type,
    this.status = DonationStatus.listed,
    required this.pickupAddress,
    this.city = 'Pune',
    this.latitude = 18.5204,
    this.longitude = 73.8567,
    required this.createdAt,
    required this.pickupDeadline,
    this.claimedByNgoId,
    this.claimedByNgoName,
    this.assignedVolunteerId,
    this.assignedVolunteerName,
    this.assignedVolunteerPhone,
    this.pickedUpAt,
    this.deliveredAt,
    this.imageUrl,
    this.isVeg = true,
    this.prepTime,
    this.storageCondition = 'ambient',
    this.allergenNotes,
    this.safetyCharterAgreed = true,
    this.clothingCategory,
    this.conditionGrade,
    this.isWashedAndClean = true,
  });

  bool get isFood => type == DonationType.food;
  bool get isClothing => type == DonationType.clothing;
  bool get isAvailable => status == DonationStatus.listed;
  bool get isClaimed => status == DonationStatus.claimed;
  bool get isAssigned => status == DonationStatus.assigned;
  bool get isInTransit => status == DonationStatus.pickedUp;
  bool get isDelivered => status == DonationStatus.delivered;

  // Safe time remaining
  Duration get timeRemaining => pickupDeadline.difference(DateTime.now());
  bool get isUrgent => isFood && timeRemaining.inHours < 3 && !timeRemaining.isNegative;

  Donation copyWith({
    String? id,
    String? donorId,
    String? donorName,
    String? donorPhone,
    String? title,
    String? description,
    double? quantity,
    String? unit,
    DonationType? type,
    DonationStatus? status,
    String? pickupAddress,
    String? city,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? pickupDeadline,
    String? claimedByNgoId,
    String? claimedByNgoName,
    String? assignedVolunteerId,
    String? assignedVolunteerName,
    String? assignedVolunteerPhone,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? imageUrl,
    bool? isVeg,
    DateTime? prepTime,
    String? storageCondition,
    String? allergenNotes,
    bool? safetyCharterAgreed,
    String? clothingCategory,
    String? conditionGrade,
    bool? isWashedAndClean,
  }) {
    return Donation(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      donorPhone: donorPhone ?? this.donorPhone,
      title: title ?? this.title,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      type: type ?? this.type,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      pickupDeadline: pickupDeadline ?? this.pickupDeadline,
      claimedByNgoId: claimedByNgoId ?? this.claimedByNgoId,
      claimedByNgoName: claimedByNgoName ?? this.claimedByNgoName,
      assignedVolunteerId: assignedVolunteerId ?? this.assignedVolunteerId,
      assignedVolunteerName: assignedVolunteerName ?? this.assignedVolunteerName,
      assignedVolunteerPhone: assignedVolunteerPhone ?? this.assignedVolunteerPhone,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      imageUrl: imageUrl ?? this.imageUrl,
      isVeg: isVeg ?? this.isVeg,
      prepTime: prepTime ?? this.prepTime,
      storageCondition: storageCondition ?? this.storageCondition,
      allergenNotes: allergenNotes ?? this.allergenNotes,
      safetyCharterAgreed: safetyCharterAgreed ?? this.safetyCharterAgreed,
      clothingCategory: clothingCategory ?? this.clothingCategory,
      conditionGrade: conditionGrade ?? this.conditionGrade,
      isWashedAndClean: isWashedAndClean ?? this.isWashedAndClean,
    );
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String,
      donorId: json['donor_id'] as String? ?? 'unknown-donor',
      donorName: json['donor_name'] as String? ?? 'FoodBridge Donor',
      donorPhone: json['donor_phone'] as String?,
      title: json['title'] as String? ?? 'Donation',
      description: json['description'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? 'items',
      type: DonationType.fromString(json['type'] as String?),
      status: DonationStatus.fromString(json['status'] as String?),
      pickupAddress: json['pickup_address'] as String? ?? '',
      city: json['city'] as String? ?? 'Pune',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 18.5204,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 73.8567,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      pickupDeadline: json['pickup_deadline'] != null
          ? DateTime.tryParse(json['pickup_deadline'] as String) ??
              DateTime.now().add(const Duration(hours: 4))
          : DateTime.now().add(const Duration(hours: 4)),
      claimedByNgoId: json['claimed_by_ngo_id'] as String?,
      claimedByNgoName: json['claimed_by_ngo_name'] as String?,
      assignedVolunteerId: json['assigned_volunteer_id'] as String?,
      assignedVolunteerName: json['assigned_volunteer_name'] as String?,
      assignedVolunteerPhone: json['assigned_volunteer_phone'] as String?,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.tryParse(json['picked_up_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'] as String)
          : null,
      imageUrl: json['image_url'] as String?,
      isVeg: json['is_veg'] as bool? ?? true,
      prepTime: json['prep_time'] != null
          ? DateTime.tryParse(json['prep_time'] as String)
          : null,
      storageCondition: json['storage_condition'] as String? ?? 'ambient',
      allergenNotes: json['allergen_notes'] as String?,
      safetyCharterAgreed: json['safety_charter_agreed'] as bool? ?? true,
      clothingCategory: json['clothing_category'] as String?,
      conditionGrade: json['condition_grade'] as String?,
      isWashedAndClean: json['is_washed_and_clean'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'donor_name': donorName,
      'donor_phone': donorPhone,
      'title': title,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'type': type.name,
      'status': status.name,
      'pickup_address': pickupAddress,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'pickup_deadline': pickupDeadline.toIso8601String(),
      'claimed_by_ngo_id': claimedByNgoId,
      'claimed_by_ngo_name': claimedByNgoName,
      'assigned_volunteer_id': assignedVolunteerId,
      'assigned_volunteer_name': assignedVolunteerName,
      'assigned_volunteer_phone': assignedVolunteerPhone,
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'image_url': imageUrl,
      'is_veg': isVeg,
      'prep_time': prepTime?.toIso8601String(),
      'storage_condition': storageCondition,
      'allergen_notes': allergenNotes,
      'safety_charter_agreed': safetyCharterAgreed,
      'clothing_category': clothingCategory,
      'condition_grade': conditionGrade,
      'is_washed_and_clean': isWashedAndClean,
    };
  }
}

