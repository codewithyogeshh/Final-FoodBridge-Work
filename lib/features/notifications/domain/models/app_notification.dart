enum NotificationType {
  newDonation,
  ngoRequest,
  requestAccepted,
  requestRejected,
  volunteerAssigned,
  pickupConfirmed,
  deliveryConfirmed,
  donationCompleted,
  donationCancelled,
  deadlineWarning;

  String get displayName {
    switch (this) {
      case NotificationType.newDonation:
        return 'New Donation Available';
      case NotificationType.ngoRequest:
        return 'Donation Claimed';
      case NotificationType.requestAccepted:
        return 'Request Accepted';
      case NotificationType.requestRejected:
        return 'Request Declined';
      case NotificationType.volunteerAssigned:
        return 'Volunteer Courier Dispatched';
      case NotificationType.pickupConfirmed:
        return 'Cargo Picked Up';
      case NotificationType.deliveryConfirmed:
        return 'Handover Confirmed';
      case NotificationType.donationCompleted:
        return 'Mission Completed';
      case NotificationType.donationCancelled:
        return 'Donation Cancelled';
      case NotificationType.deadlineWarning:
        return 'Urgent: Deadline Approaching';
    }
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedDonationId;
  final String? actionRoute;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedDonationId,
    this.actionRoute,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? relatedDonationId,
    String? actionRoute,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedDonationId: relatedDonationId ?? this.relatedDonationId,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.newDonation,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      relatedDonationId: json['related_donation_id'] as String?,
      actionRoute: json['action_route'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'related_donation_id': relatedDonationId,
      'action_route': actionRoute,
    };
  }
}

class NotificationPreferences {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool deadlineAlerts;
  final bool nearbyDonationsAlerts;
  final bool statusChangeAlerts;
  final bool soundEnabled;

  const NotificationPreferences({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.deadlineAlerts = true,
    this.nearbyDonationsAlerts = true,
    this.statusChangeAlerts = true,
    this.soundEnabled = true,
  });

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? deadlineAlerts,
    bool? nearbyDonationsAlerts,
    bool? statusChangeAlerts,
    bool? soundEnabled,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      deadlineAlerts: deadlineAlerts ?? this.deadlineAlerts,
      nearbyDonationsAlerts:
          nearbyDonationsAlerts ?? this.nearbyDonationsAlerts,
      statusChangeAlerts: statusChangeAlerts ?? this.statusChangeAlerts,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

