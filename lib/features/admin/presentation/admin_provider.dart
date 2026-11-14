import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../authentication/data/auth_service.dart';
import '../../authentication/domain/models/app_user.dart';
import '../../donations/domain/models/donation.dart';
import '../domain/models/audit_log.dart';
import '../domain/models/complaint.dart';

class ManagedUser {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final bool isSuspended;
  final String? suspensionReason;
  final DateTime createdAt;

  const ManagedUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.isSuspended = false,
    this.suspensionReason,
    required this.createdAt,
  });

  ManagedUser copyWith({
    String? id,
    String? fullName,
    String? email,
    UserRole? role,
    bool? isSuspended,
    String? suspensionReason,
    bool clearSuspensionReason = false,
    DateTime? createdAt,
  }) {
    return ManagedUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: clearSuspensionReason
          ? null
          : (suspensionReason ?? this.suspensionReason),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PendingNgoApplication {
  final String id;
  final String name;
  final String regNo;
  final String darpanId;
  final String contactPerson;
  final String phone;
  final String documentName;
  final String? documentPath;
  final String? email;
  final DateTime appliedAt;

  const PendingNgoApplication({
    required this.id,
    required this.name,
    required this.regNo,
    required this.darpanId,
    required this.contactPerson,
    required this.phone,
    required this.documentName,
    this.documentPath,
    this.email,
    required this.appliedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'regNo': regNo,
    'darpanId': darpanId,
    'contactPerson': contactPerson,
    'phone': phone,
    'documentName': documentName,
    'documentPath': documentPath,
    'email': email,
    'appliedAt': appliedAt.toIso8601String(),
  };

  factory PendingNgoApplication.fromJson(Map<String, dynamic> map) => PendingNgoApplication(
    id: map['id'] as String? ?? 'ngo-app-${DateTime.now().millisecondsSinceEpoch}',
    name: map['name'] as String? ?? 'NGO Shelter',
    regNo: map['regNo'] as String? ?? '',
    darpanId: map['darpanId'] as String? ?? '',
    contactPerson: map['contactPerson'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    documentName: map['documentName'] as String? ?? 'Document.pdf',
    documentPath: map['documentPath'] as String?,
    email: map['email'] as String?,
    appliedAt: DateTime.tryParse(map['appliedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class AdminProvider extends ChangeNotifier {
  static const String _kPendingNgosStorageKey = 'foodbridge_pending_ngos_key_v1';

  final List<PendingNgoApplication> _pendingNgos = [];
  final List<ManagedUser> _managedUsers = [];
  final List<Complaint> _complaints = [];
  final List<AuditLogEntry> _auditLogs = [];
  final bool _isLoading = false;
  String? _errorMessage;

  AdminProvider() {
    _seedInitialAdminData();
    _loadPendingNgos();
  }

  List<PendingNgoApplication> get pendingNgos => List.unmodifiable(_pendingNgos);
  List<ManagedUser> get managedUsers => List.unmodifiable(_managedUsers);
  List<Complaint> get complaints => List.unmodifiable(_complaints);
  List<AuditLogEntry> get auditLogs => List.unmodifiable(_auditLogs);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingNgoCount => _pendingNgos.length;
  int get openComplaintsCount =>
      _complaints.where((c) => c.status == ComplaintStatus.open).length;

  Future<void> _persistPendingNgos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _pendingNgos.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_kPendingNgosStorageKey, list);
    } catch (_) {}
  }

  Future<void> _loadPendingNgos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kPendingNgosStorageKey);
      if (list != null && list.isNotEmpty) {
        _pendingNgos.clear();
        for (final item in list) {
          try {
            final map = jsonDecode(item) as Map<String, dynamic>;
            _pendingNgos.add(PendingNgoApplication.fromJson(map));
          } catch (_) {}
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  void addPendingNgoApplication(PendingNgoApplication app) {
    _pendingNgos.removeWhere((n) => n.id == app.id || (app.email != null && n.email == app.email));
    _pendingNgos.insert(0, app);
    _persistPendingNgos();
    notifyListeners();
  }

  /// 1. NGO Verification: Approve
  Future<bool> approveNgo({
    required String ngoId,
    required String adminId,
    bool isAdmin = true,
  }) async {
    if (!isAdmin) {
      _errorMessage = 'Unauthorized: Only platform administrators can approve NGOs.';
      notifyListeners();
      return false;
    }

    final index = _pendingNgos.indexWhere((n) => n.id == ngoId);
    if (index == -1) return false;

    final app = _pendingNgos[index];
    _pendingNgos.removeAt(index);
    await _persistPendingNgos();

    // Mark verified in AuthService so NGO can now log in
    await AuthService().verifyNgo(
      ngoId: app.id,
      email: app.email,
      organizationName: app.name,
      darpanId: app.darpanId,
      registrationNumber: app.regNo,
    );

    // Add to managed users
    _managedUsers.add(
      ManagedUser(
        id: app.id,
        fullName: app.name,
        email: app.email ?? '${app.id}@foodbridge.org',
        role: UserRole.ngo,
        createdAt: app.appliedAt,
      ),
    );

    _logAudit(
      actorId: adminId,
      actorRole: 'admin',
      action: 'NGO_VERIFICATION_APPROVED',
      targetEntity: 'ngo_profiles',
      targetId: app.id,
      details: 'Approved NGO "${app.name}" with Darpan ID: ${app.darpanId}',
    );

    notifyListeners();
    return true;
  }

  /// 1. NGO Verification: Reject
  Future<bool> rejectNgo({
    required String ngoId,
    required String reason,
    required String adminId,
    bool isAdmin = true,
  }) async {
    if (!isAdmin) {
      _errorMessage = 'Unauthorized: Only platform administrators can reject NGOs.';
      notifyListeners();
      return false;
    }

    final index = _pendingNgos.indexWhere((n) => n.id == ngoId);
    if (index == -1) return false;

    final app = _pendingNgos[index];
    _pendingNgos.removeAt(index);
    await _persistPendingNgos();

    await AuthService().rejectNgo(
      ngoId: app.id,
      email: app.email,
    );

    _logAudit(
      actorId: adminId,
      actorRole: 'admin',
      action: 'NGO_VERIFICATION_REJECTED',
      targetEntity: 'ngo_profiles',
      targetId: app.id,
      details: 'Rejected NGO "${app.name}". Reason: $reason',
    );

    notifyListeners();
    return true;
  }

  /// 2. User Management: Suspend User
  Future<bool> suspendUser({
    required String userId,
    required String reason,
    required String adminId,
    bool isAdmin = true,
  }) async {
    if (!isAdmin) {
      _errorMessage = 'Unauthorized: Only platform administrators can suspend accounts.';
      notifyListeners();
      return false;
    }

    final index = _managedUsers.indexWhere((u) => u.id == userId);
    if (index == -1) return false;

    final user = _managedUsers[index];
    _managedUsers[index] = user.copyWith(
      isSuspended: true,
      suspensionReason: reason,
    );

    _logAudit(
      actorId: adminId,
      actorRole: 'admin',
      action: 'USER_ACCOUNT_SUSPENDED',
      targetEntity: 'profiles',
      targetId: user.id,
      details: 'Suspended user "${user.fullName}" (${user.email}). Reason: $reason',
    );

    notifyListeners();
    return true;
  }

  /// 2. User Management: Reactivate User
  Future<bool> reactivateUser({
    required String userId,
    required String adminId,
    bool isAdmin = true,
  }) async {
    if (!isAdmin) {
      _errorMessage = 'Unauthorized: Only platform administrators can reactivate accounts.';
      notifyListeners();
      return false;
    }

    final index = _managedUsers.indexWhere((u) => u.id == userId);
    if (index == -1) return false;

    final user = _managedUsers[index];
    _managedUsers[index] = user.copyWith(
      isSuspended: false,
      clearSuspensionReason: true,
    );

    _logAudit(
      actorId: adminId,
      actorRole: 'admin',
      action: 'USER_ACCOUNT_REACTIVATED',
      targetEntity: 'profiles',
      targetId: user.id,
      details: 'Reactivated user account "${user.fullName}" (${user.email}).',
    );

    notifyListeners();
    return true;
  }

  /// 3. Complaint Management: Resolve
  Future<bool> resolveComplaint({
    required String complaintId,
    required String resolutionNotes,
    required String adminId,
    bool isAdmin = true,
  }) async {
    if (!isAdmin) {
      _errorMessage = 'Unauthorized: Only administrators can resolve complaints.';
      notifyListeners();
      return false;
    }

    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index == -1) return false;

    final current = _complaints[index];
    _complaints[index] = current.copyWith(
      status: ComplaintStatus.resolved,
      resolutionNotes: resolutionNotes,
      resolvedAt: DateTime.now(),
    );

    _logAudit(
      actorId: adminId,
      actorRole: 'admin',
      action: 'COMPLAINT_RESOLVED',
      targetEntity: 'complaints',
      targetId: current.id,
      details: 'Resolved complaint #${current.id} (${current.category}): $resolutionNotes',
    );

    notifyListeners();
    return true;
  }

  /// 3. Complaint Management: Dismiss
  Future<bool> dismissComplaint({
    required String complaintId,
    required String reason,
    required String adminId,
    bool isAdmin = true,
  }) async {
    if (!isAdmin) return false;

    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index == -1) return false;

    final current = _complaints[index];
    _complaints[index] = current.copyWith(
      status: ComplaintStatus.dismissed,
      resolutionNotes: 'Dismissed: $reason',
      resolvedAt: DateTime.now(),
    );

    _logAudit(
      actorId: adminId,
      actorRole: 'admin',
      action: 'COMPLAINT_DISMISSED',
      targetEntity: 'complaints',
      targetId: current.id,
      details: 'Dismissed complaint #${current.id}: $reason',
    );

    notifyListeners();
    return true;
  }

  /// 4. Audit Log recording
  void _logAudit({
    required String actorId,
    required String actorRole,
    required String action,
    required String targetEntity,
    required String targetId,
    required String details,
  }) {
    final entry = AuditLogEntry(
      id: 'audit-${DateTime.now().millisecondsSinceEpoch}-${_auditLogs.length}',
      actorId: actorId,
      actorRole: actorRole,
      action: action,
      targetEntity: targetEntity,
      targetId: targetId,
      details: details,
      timestamp: DateTime.now(),
    );
    _auditLogs.insert(0, entry);
  }

  /// 5. Database-Backed Analytics Calculation
  Map<String, dynamic> computeAnalytics(List<Donation> allDonations) {
    final total = allDonations.length;
    final food = allDonations.where((d) => d.isFood).length;
    final clothing = allDonations.where((d) => d.isClothing).length;

    final available = allDonations
        .where((d) =>
            d.status == DonationStatus.available ||
            d.status == DonationStatus.listed)
        .length;

    final claimed = allDonations
        .where((d) =>
            d.status == DonationStatus.accepted ||
            d.status == DonationStatus.claimed)
        .length;

    final inTransit = allDonations
        .where((d) =>
            d.status == DonationStatus.assigned ||
            d.status == DonationStatus.assignedForPickup ||
            d.status == DonationStatus.pickedUp)
        .length;

    final delivered = allDonations
        .where((d) =>
            d.status == DonationStatus.delivered ||
            d.status == DonationStatus.deliveredToNgo ||
            d.status == DonationStatus.distributed ||
            d.status == DonationStatus.completed)
        .length;

    final uniqueNgos = allDonations
        .where((d) => d.claimedByNgoId != null)
        .map((d) => d.claimedByNgoId!)
        .toSet()
        .length;

    final uniqueVolunteers = allDonations
        .where((d) => d.assignedVolunteerId != null)
        .map((d) => d.assignedVolunteerId!)
        .toSet()
        .length;

    final totalMeals = allDonations
        .where((d) =>
            d.isFood &&
            (d.status == DonationStatus.delivered ||
                d.status == DonationStatus.deliveredToNgo ||
                d.status == DonationStatus.distributed ||
                d.status == DonationStatus.completed))
        .fold<double>(0.0, (acc, item) => acc + item.quantity);

    final totalClothes = allDonations
        .where((d) =>
            d.isClothing &&
            (d.status == DonationStatus.delivered ||
                d.status == DonationStatus.deliveredToNgo ||
                d.status == DonationStatus.distributed ||
                d.status == DonationStatus.completed))
        .fold<int>(0, (acc, item) => acc + item.quantity.toInt());

    final completed = allDonations
        .where((d) => d.status == DonationStatus.completed)
        .length;

    return {
      'totalDonations': total,
      'availableDonations': available,
      'claimedDonations': claimed,
      'inTransitDonations': inTransit,
      'deliveredDonations': delivered,
      'completedDonations': completed,
      'successfulDeliveries': delivered,
      'foodDonations': food,
      'clothingDonations': clothing,
      'activeNgos': uniqueNgos,
      'activeVolunteers': uniqueVolunteers,
      'totalMealsRescued': totalMeals,
      'totalClothingItems': totalClothes,
    };
  }

  void _seedInitialAdminData() {
    final now = DateTime.now();

    _pendingNgos.addAll([
      PendingNgoApplication(
        id: 'ngo-app-1',
        name: 'Seva Deep Foundation',
        regNo: 'MH/2023/008129',
        darpanId: 'MH/2023/DARPAN-4412',
        contactPerson: 'Sunita Rao',
        phone: '+91 98223 44556',
        documentName: '12A_80G_Certificate.pdf',
        appliedAt: now.subtract(const Duration(hours: 4)),
      ),
      PendingNgoApplication(
        id: 'ngo-app-2',
        name: 'Pune City Hunger Relief',
        regNo: 'MH/2021/004921',
        darpanId: 'MH/2021/DARPAN-8910',
        contactPerson: 'Anand Deshmukh',
        phone: '+91 97654 33221',
        documentName: 'Trust_Deed_FCRA.pdf',
        appliedAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    _managedUsers.addAll([
      ManagedUser(
        id: 'usr-donor-101',
        fullName: 'The Green Leaf Bistro',
        email: 'donor@foodbridge.org',
        role: UserRole.donor,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      ManagedUser(
        id: 'usr-ngo-202',
        fullName: 'Asha Children Foundation',
        email: 'ngo@foodbridge.org',
        role: UserRole.ngo,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      ManagedUser(
        id: 'usr-vol-303',
        fullName: 'Rohit Kulkarni',
        email: 'volunteer@foodbridge.org',
        role: UserRole.volunteer,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      ManagedUser(
        id: 'usr-donor-404',
        fullName: 'Flagged Commercial Caterer',
        email: 'spammer@caterers.com',
        role: UserRole.donor,
        isSuspended: true,
        suspensionReason: 'Repeated non-hygienic packaging reports and late cancellation.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);

    _complaints.addAll([
      Complaint(
        id: 'cmp-101',
        reporterName: 'Asha Children Foundation',
        reporterRole: 'ngo',
        respondentName: 'Flagged Commercial Caterer',
        category: 'Quality / Hygiene',
        description: 'Food was not packed in leak-proof containers as per declaration.',
        status: ComplaintStatus.open,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Complaint(
        id: 'cmp-102',
        reporterName: 'Rohit Kulkarni (Volunteer)',
        reporterRole: 'volunteer',
        respondentName: 'Midnight Cafe',
        category: 'No-show / Delay',
        description: 'Donor was closed during designated pickup window.',
        status: ComplaintStatus.resolved,
        resolutionNotes: 'Donor contacted and warned; compensated volunteer fuel allowance.',
        createdAt: now.subtract(const Duration(days: 2)),
        resolvedAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    _auditLogs.addAll([
      AuditLogEntry(
        id: 'audit-1',
        actorId: 'usr-admin-001',
        actorRole: 'admin',
        action: 'DONATION_CLAIMED',
        targetEntity: 'donations',
        targetId: 'dn-101',
        details: 'Asha Shelter claimed 50 Veg Biryani Meal Boxes',
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      AuditLogEntry(
        id: 'audit-2',
        actorId: 'usr-vol-303',
        actorRole: 'volunteer',
        action: 'VOLUNTEER_ASSIGNED',
        targetEntity: 'donations',
        targetId: 'dn-102',
        details: 'Rohit Kulkarni accepted dispatch task #dn-102',
        timestamp: now.subtract(const Duration(minutes: 18)),
      ),
      AuditLogEntry(
        id: 'audit-3',
        actorId: 'usr-donor-101',
        actorRole: 'donor',
        action: 'DONATION_CREATED',
        targetEntity: 'donations',
        targetId: 'dn-101',
        details: 'The Green Leaf Bistro published 50 Veg Biryani Meal Boxes',
        timestamp: now.subtract(const Duration(minutes: 45)),
      ),
      AuditLogEntry(
        id: 'audit-4',
        actorId: 'usr-admin-001',
        actorRole: 'admin',
        action: 'USER_ACCOUNT_SUSPENDED',
        targetEntity: 'profiles',
        targetId: 'usr-donor-404',
        details: 'Suspended Flagged Commercial Caterer for repeated hygiene infractions',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }
}
