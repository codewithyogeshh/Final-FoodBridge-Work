import 'package:latlong2/latlong.dart';

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
  draft,
  available,
  requested,
  accepted,
  assignedForPickup,
  pickedUp,
  deliveredToNgo,
  distributed,
  completed,
  cancelled,
  expired,
  rejected;

  // Backward compatibility getters
  static DonationStatus get listed => available;
  static DonationStatus get claimed => accepted;
  static DonationStatus get assigned => assignedForPickup;
  static DonationStatus get delivered => deliveredToNgo;

  String get displayName {
    switch (this) {
      case DonationStatus.draft:
        return 'Draft';
      case DonationStatus.available:
        return 'Available';
      case DonationStatus.requested:
        return 'Requested';
      case DonationStatus.accepted:
        return 'Accepted / Claimed';
      case DonationStatus.assignedForPickup:
        return 'Volunteer Assigned';
      case DonationStatus.pickedUp:
        return 'In Transit';
      case DonationStatus.deliveredToNgo:
        return 'Delivered to Shelter';
      case DonationStatus.distributed:
        return 'Distributed to People';
      case DonationStatus.completed:
        return 'Completed';
      case DonationStatus.cancelled:
        return 'Cancelled';
      case DonationStatus.expired:
        return 'Expired';
      case DonationStatus.rejected:
        return 'Rejected';
    }
  }

  static DonationStatus fromString(String? status) {
    switch (status?.toLowerCase().trim()) {
      case 'draft':
        return DonationStatus.draft;
      case 'requested':
        return DonationStatus.requested;
      case 'accepted':
      case 'claimed':
        return DonationStatus.accepted;
      case 'assigned_for_pickup':
      case 'assignedforpickup':
      case 'assigned':
        return DonationStatus.assignedForPickup;
      case 'pickedup':
      case 'picked_up':
      case 'intransit':
      case 'in_transit':
        return DonationStatus.pickedUp;
      case 'delivered_to_ngo':
      case 'deliveredtongo':
      case 'delivered':
        return DonationStatus.deliveredToNgo;
      case 'distribution_recorded':
      case 'distributed':
        return DonationStatus.distributed;
      case 'completed':
        return DonationStatus.completed;
      case 'cancelled':
        return DonationStatus.cancelled;
      case 'expired':
        return DonationStatus.expired;
      case 'rejected':
        return DonationStatus.rejected;
      case 'available':
      case 'listed':
      default:
        return DonationStatus.available;
    }
  }

  bool canTransitionTo(DonationStatus next) {
    switch (this) {
      case DonationStatus.draft:
        return next == DonationStatus.available || next == DonationStatus.cancelled;
      case DonationStatus.available:
        return next == DonationStatus.requested ||
            next == DonationStatus.accepted ||
            next == DonationStatus.cancelled ||
            next == DonationStatus.expired;
      case DonationStatus.requested:
        return next == DonationStatus.accepted ||
            next == DonationStatus.rejected ||
            next == DonationStatus.available ||
            next == DonationStatus.cancelled;
      case DonationStatus.accepted:
        return next == DonationStatus.assignedForPickup ||
            next == DonationStatus.pickedUp ||
            next == DonationStatus.available ||
            next == DonationStatus.cancelled;
      case DonationStatus.assignedForPickup:
        return next == DonationStatus.pickedUp ||
            next == DonationStatus.accepted ||
            next == DonationStatus.cancelled;
      case DonationStatus.pickedUp:
        return next == DonationStatus.deliveredToNgo || next == DonationStatus.cancelled;
      case DonationStatus.deliveredToNgo:
        return next == DonationStatus.distributed || next == DonationStatus.completed;
      case DonationStatus.distributed:
        return next == DonationStatus.completed;
      case DonationStatus.completed:
      case DonationStatus.cancelled:
      case DonationStatus.expired:
      case DonationStatus.rejected:
        return false;
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
  final DateTime? claimedAt;
  final String? assignedVolunteerId;
  final String? assignedVolunteerName;
  final String? assignedVolunteerPhone;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? imageUrl;
  final String pickupOtp;
  final String deliveryOtp;
  final String dropoffAddress;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final double? courierLatitude;
  final double? courierLongitude;
  final double? courierHeading;
  final double estimatedDistanceKm;
  final int estimatedMinutes;

  // Food specific attributes
  final bool isVeg;
  final DateTime? prepTime;
  final String? storageCondition; // 'ambient', 'chilled', 'hot'
  final String? allergenNotes;
  final bool safetyCharterAgreed;

  // Clothing specific attributes
  final String? clothingCategory; // 'kids', 'adults', 'winter', 'blankets'
  final String? targetSize;
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
    this.status = DonationStatus.available,
    required this.pickupAddress,
    this.city = 'Satara',
    this.latitude = 17.6805,
    this.longitude = 73.9934,
    required this.createdAt,
    required this.pickupDeadline,
    this.claimedByNgoId,
    this.claimedByNgoName,
    this.claimedAt,
    this.assignedVolunteerId,
    this.assignedVolunteerName,
    this.assignedVolunteerPhone,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.imageUrl,
    this.pickupOtp = '4829',
    this.deliveryOtp = '9152',
    this.dropoffAddress = 'Asha Children Shelter, Sadar Bazar, Satara',
    this.dropoffLatitude = 17.6920,
    this.dropoffLongitude = 74.0020,
    this.courierLatitude,
    this.courierLongitude,
    this.courierHeading,
    this.estimatedDistanceKm = 3.8,
    this.estimatedMinutes = 14,
    this.isVeg = true,
    this.prepTime,
    this.storageCondition = 'ambient',
    this.allergenNotes,
    this.safetyCharterAgreed = true,
    this.clothingCategory,
    this.targetSize,
    this.conditionGrade,
    this.isWashedAndClean = true,
  });

  bool get isFood => type == DonationType.food;
  bool get isClothing => type == DonationType.clothing;
  bool get isDraft => status == DonationStatus.draft;

  LatLng get pickupLatLng => LatLng(latitude, longitude);
  LatLng get dropoffLatLng => LatLng(
        dropoffLatitude ?? (latitude + 0.0115),
        dropoffLongitude ?? (longitude + 0.0086),
      );
  LatLng get liveCourierLatLng {
    if (courierLatitude != null && courierLongitude != null) {
      return LatLng(courierLatitude!, courierLongitude!);
    }
    if (status == DonationStatus.pickedUp) {
      return LatLng(
        (latitude + (dropoffLatitude ?? (latitude + 0.0115))) / 2,
        (longitude + (dropoffLongitude ?? (longitude + 0.0086))) / 2,
      );
    }
    return LatLng(latitude + 0.003, longitude + 0.002);
  }
  bool get isAvailable =>
      !isDelivered &&
      !isDistributed &&
      !isCompleted &&
      !isExpired &&
      (status == DonationStatus.available || status == DonationStatus.listed) &&
      (claimedByNgoName == null || claimedByNgoName!.trim().isEmpty) &&
      (claimedByNgoId == null || claimedByNgoId!.trim().isEmpty);
  bool get isRequested => status == DonationStatus.requested;
  bool get isClaimed =>
      !isDelivered &&
      !isDistributed &&
      !isCompleted &&
      !isExpired &&
      (status == DonationStatus.accepted ||
          status == DonationStatus.claimed ||
          (claimedByNgoName != null && claimedByNgoName!.trim().isNotEmpty) ||
          (claimedByNgoId != null && claimedByNgoId!.trim().isNotEmpty));
  bool get isAssigned =>
      !isDelivered &&
      !isDistributed &&
      !isCompleted &&
      !isExpired &&
      (status == DonationStatus.assignedForPickup ||
          status == DonationStatus.assigned ||
          (assignedVolunteerId != null && assignedVolunteerId!.trim().isNotEmpty));
  bool get isInTransit => !isDelivered && !isDistributed && !isCompleted && !isExpired && status == DonationStatus.pickedUp;
  bool get isDelivered =>
      status == DonationStatus.deliveredToNgo ||
      status == DonationStatus.delivered ||
      status == DonationStatus.distributed ||
      status == DonationStatus.completed ||
      deliveredAt != null;
  bool get isDistributed => status == DonationStatus.distributed;
  bool get isCompleted => status == DonationStatus.completed;
  bool get isCancelled => status == DonationStatus.cancelled;
  bool get isExpired =>
      status == DonationStatus.expired ||
      (!isDelivered &&
          !isDistributed &&
          !isCompleted &&
          !isCancelled &&
          pickupDeadline.isBefore(DateTime.now()));
  bool get isRejected => status == DonationStatus.rejected;

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
    DateTime? claimedAt,
    String? assignedVolunteerId,
    String? assignedVolunteerName,
    String? assignedVolunteerPhone,
    DateTime? assignedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? imageUrl,
    String? pickupOtp,
    String? deliveryOtp,
    String? dropoffAddress,
    double? dropoffLatitude,
    double? dropoffLongitude,
    double? courierLatitude,
    double? courierLongitude,
    double? courierHeading,
    double? estimatedDistanceKm,
    int? estimatedMinutes,
    bool? isVeg,
    DateTime? prepTime,
    String? storageCondition,
    String? allergenNotes,
    bool? safetyCharterAgreed,
    String? clothingCategory,
    String? targetSize,
    String? conditionGrade,
    bool? isWashedAndClean,
    bool clearVolunteerAssignment = false,
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
      claimedAt: claimedAt ?? this.claimedAt,
      assignedVolunteerId: clearVolunteerAssignment
          ? null
          : (assignedVolunteerId ?? this.assignedVolunteerId),
      assignedVolunteerName: clearVolunteerAssignment
          ? null
          : (assignedVolunteerName ?? this.assignedVolunteerName),
      assignedVolunteerPhone: clearVolunteerAssignment
          ? null
          : (assignedVolunteerPhone ?? this.assignedVolunteerPhone),
      assignedAt:
          clearVolunteerAssignment ? null : (assignedAt ?? this.assignedAt),
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      imageUrl: imageUrl ?? this.imageUrl,
      pickupOtp: pickupOtp ?? this.pickupOtp,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      courierLatitude: courierLatitude ?? this.courierLatitude,
      courierLongitude: courierLongitude ?? this.courierLongitude,
      courierHeading: courierHeading ?? this.courierHeading,
      estimatedDistanceKm: estimatedDistanceKm ?? this.estimatedDistanceKm,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isVeg: isVeg ?? this.isVeg,
      prepTime: prepTime ?? this.prepTime,
      storageCondition: storageCondition ?? this.storageCondition,
      allergenNotes: allergenNotes ?? this.allergenNotes,
      safetyCharterAgreed: safetyCharterAgreed ?? this.safetyCharterAgreed,
      clothingCategory: clothingCategory ?? this.clothingCategory,
      targetSize: targetSize ?? this.targetSize,
      conditionGrade: conditionGrade ?? this.conditionGrade,
      isWashedAndClean: isWashedAndClean ?? this.isWashedAndClean,
    );
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString();
    final claimedNgo = json['claimed_by_ngo_name']?.toString();
    final claimedId = json['claimed_by_ngo_id']?.toString();
    final volId = json['assigned_volunteer_id']?.toString();
    final volName = json['assigned_volunteer_name']?.toString();
    final rawDeliveredAt = json['delivered_at'];

    DonationStatus parsedStatus = DonationStatus.fromString(rawStatus);

    if (rawDeliveredAt != null && rawDeliveredAt.toString().trim().isNotEmpty) {
      parsedStatus = DonationStatus.deliveredToNgo;
    } else {
      if ((claimedNgo != null && claimedNgo.trim().isNotEmpty) ||
          (claimedId != null && claimedId.trim().isNotEmpty)) {
        if (parsedStatus == DonationStatus.available ||
            parsedStatus == DonationStatus.draft) {
          parsedStatus = DonationStatus.accepted;
        }
      }

      if ((volId != null && volId.trim().isNotEmpty) ||
          (volName != null && volName.trim().isNotEmpty)) {
        if (parsedStatus == DonationStatus.available ||
            parsedStatus == DonationStatus.draft ||
            parsedStatus == DonationStatus.accepted) {
          parsedStatus = DonationStatus.assignedForPickup;
        }
      }
    }

    final rawPickupAddress = json['pickup_address']?.toString() ?? '';
    String parsedCity = json['city']?.toString() ?? 'Satara';
    final addrLower = rawPickupAddress.toLowerCase();
    if (addrLower.contains('satara')) {
      parsedCity = 'Satara';
    } else if (parsedCity.toLowerCase() == 'pune' && !addrLower.contains('pune')) {
      // Default hub is Satara for local addresses that do not explicitly belong to Pune
      parsedCity = 'Satara';
    }

    return Donation(
      id: json['id']?.toString() ?? '',
      donorId: json['donor_id']?.toString() ?? 'unknown-donor',
      donorName: json['donor_name']?.toString() ?? 'FoodBridge Donor',
      donorPhone: json['donor_phone']?.toString(),
      title: json['title']?.toString() ?? 'Donation',
      description: json['description']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit']?.toString() ?? 'items',
      type: DonationType.fromString(json['type']?.toString()),
      status: parsedStatus,
      pickupAddress: rawPickupAddress,
      city: parsedCity,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 17.6805,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 73.9934,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      pickupDeadline: json['pickup_deadline'] != null
          ? DateTime.tryParse(json['pickup_deadline'].toString()) ??
              DateTime.now().add(const Duration(hours: 4))
          : DateTime.now().add(const Duration(hours: 4)),
      claimedByNgoId: json['claimed_by_ngo_id']?.toString(),
      claimedByNgoName: json['claimed_by_ngo_name']?.toString(),
      claimedAt: json['claimed_at'] != null
          ? DateTime.tryParse(json['claimed_at'].toString())
          : null,
      assignedVolunteerId: json['assigned_volunteer_id']?.toString(),
      assignedVolunteerName: json['assigned_volunteer_name']?.toString(),
      assignedVolunteerPhone: json['assigned_volunteer_phone']?.toString(),
      assignedAt: json['assigned_at'] != null
          ? DateTime.tryParse(json['assigned_at'].toString())
          : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.tryParse(json['picked_up_at'].toString())
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'].toString())
          : null,
      imageUrl: json['image_url']?.toString(),
      pickupOtp: json['pickup_otp']?.toString() ?? '4829',
      deliveryOtp: json['delivery_otp']?.toString() ?? '9152',
      dropoffAddress: json['dropoff_address']?.toString() ??
          'Asha Children Shelter, Sadar Bazar, Satara',
      dropoffLatitude: (json['dropoff_latitude'] as num?)?.toDouble() ?? 17.6920,
      dropoffLongitude: (json['dropoff_longitude'] as num?)?.toDouble() ?? 74.0020,
      courierLatitude: (json['courier_latitude'] as num?)?.toDouble(),
      courierLongitude: (json['courier_longitude'] as num?)?.toDouble(),
      courierHeading: (json['courier_heading'] as num?)?.toDouble(),
      estimatedDistanceKm:
          (json['estimated_distance_km'] as num?)?.toDouble() ?? 3.8,
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 14,
      isVeg: json['is_veg'] is bool
          ? json['is_veg'] as bool
          : (json['is_veg']?.toString().toLowerCase() == 'true'),
      prepTime: json['prep_time'] != null
          ? DateTime.tryParse(json['prep_time'].toString())
          : null,
      storageCondition: json['storage_condition']?.toString() ?? 'ambient',
      allergenNotes: json['allergen_notes']?.toString(),
      safetyCharterAgreed: json['safety_charter_agreed'] is bool
          ? json['safety_charter_agreed'] as bool
          : true,
      clothingCategory: json['clothing_category']?.toString(),
      targetSize: json['target_size']?.toString(),
      conditionGrade: json['condition_grade']?.toString(),
      isWashedAndClean: json['is_washed_and_clean'] is bool
          ? json['is_washed_and_clean'] as bool
          : true,
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
      'claimed_at': claimedAt?.toIso8601String(),
      'assigned_volunteer_id': assignedVolunteerId,
      'assigned_volunteer_name': assignedVolunteerName,
      'assigned_volunteer_phone': assignedVolunteerPhone,
      'assigned_at': assignedAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'image_url': imageUrl,
      'pickup_otp': pickupOtp,
      'delivery_otp': deliveryOtp,
      'dropoff_address': dropoffAddress,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'courier_latitude': courierLatitude,
      'courier_longitude': courierLongitude,
      'courier_heading': courierHeading,
      'estimated_distance_km': estimatedDistanceKm,
      'estimated_minutes': estimatedMinutes,
      'is_veg': isVeg,
      'prep_time': prepTime?.toIso8601String(),
      'storage_condition': storageCondition,
      'allergen_notes': allergenNotes,
      'safety_charter_agreed': safetyCharterAgreed,
      'clothing_category': clothingCategory,
      'target_size': targetSize,
      'condition_grade': conditionGrade,
      'is_washed_and_clean': isWashedAndClean,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Donation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
