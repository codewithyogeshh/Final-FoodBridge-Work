import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/admin/domain/models/complaint.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';
import 'package:foodbridge/features/donations/domain/models/donation.dart';

void main() {
  group('AdminProvider & Administration Tests (SDLC Phase 9)', () {
    late AdminProvider adminProvider;

    setUp(() {
      adminProvider = AdminProvider();
    });

    test('Initial seeded state contains pending NGOs, users, complaints, and audit logs', () {
      expect(adminProvider.pendingNgos.isNotEmpty, isTrue);
      expect(adminProvider.managedUsers.isNotEmpty, isTrue);
      expect(adminProvider.complaints.isNotEmpty, isTrue);
      expect(adminProvider.auditLogs.isNotEmpty, isTrue);
      expect(adminProvider.pendingNgoCount, 2);
      expect(adminProvider.openComplaintsCount, 1);
    });

    test('Approve NGO removes application and appends audit log entry', () async {
      final initialCount = adminProvider.pendingNgos.length;
      final targetApp = adminProvider.pendingNgos.first;

      final success = await adminProvider.approveNgo(
        ngoId: targetApp.id,
        adminId: 'admin-super-01',
        isAdmin: true,
      );

      expect(success, isTrue);
      expect(adminProvider.pendingNgos.length, initialCount - 1);
      expect(adminProvider.pendingNgos.any((n) => n.id == targetApp.id), isFalse);

      final latestAudit = adminProvider.auditLogs.first;
      expect(latestAudit.action, 'NGO_VERIFICATION_APPROVED');
      expect(latestAudit.targetId, targetApp.id);
      expect(latestAudit.details, contains(targetApp.name));
    });

    test('Reject NGO with reason removes application and logs audit entry', () async {
      final initialCount = adminProvider.pendingNgos.length;
      final targetApp = adminProvider.pendingNgos.last;

      final success = await adminProvider.rejectNgo(
        ngoId: targetApp.id,
        reason: 'Expired 80G tax exemption certificate',
        adminId: 'admin-super-01',
        isAdmin: true,
      );

      expect(success, isTrue);
      expect(adminProvider.pendingNgos.length, initialCount - 1);
      expect(adminProvider.pendingNgos.any((n) => n.id == targetApp.id), isFalse);

      final latestAudit = adminProvider.auditLogs.first;
      expect(latestAudit.action, 'NGO_VERIFICATION_REJECTED');
      expect(latestAudit.targetId, targetApp.id);
      expect(latestAudit.details, contains('Expired 80G tax exemption certificate'));
    });

    test('Non-admin user cannot approve or reject NGOs (Authorization guard)', () async {
      final initialCount = adminProvider.pendingNgos.length;
      final targetApp = adminProvider.pendingNgos.first;

      final success = await adminProvider.approveNgo(
        ngoId: targetApp.id,
        adminId: 'intruder-user-99',
        isAdmin: false,
      );

      expect(success, isFalse);
      expect(adminProvider.pendingNgos.length, initialCount);
      expect(adminProvider.errorMessage, contains('Unauthorized'));

      final rejectSuccess = await adminProvider.rejectNgo(
        ngoId: targetApp.id,
        reason: 'Malicious attempt',
        adminId: 'intruder-user-99',
        isAdmin: false,
      );

      expect(rejectSuccess, isFalse);
      expect(adminProvider.pendingNgos.length, initialCount);
    });

    test('Suspend user updates suspension state and records audit log', () async {
      final activeUser = adminProvider.managedUsers.firstWhere((u) => !u.isSuspended);

      final success = await adminProvider.suspendUser(
        userId: activeUser.id,
        reason: 'Inappropriate donor behavior and repeated cancellations',
        adminId: 'admin-super-01',
        isAdmin: true,
      );

      expect(success, isTrue);
      final updatedUser = adminProvider.managedUsers.firstWhere((u) => u.id == activeUser.id);
      expect(updatedUser.isSuspended, isTrue);
      expect(updatedUser.suspensionReason, contains('Inappropriate donor behavior'));

      final latestAudit = adminProvider.auditLogs.first;
      expect(latestAudit.action, 'USER_ACCOUNT_SUSPENDED');
      expect(latestAudit.targetId, activeUser.id);
    });

    test('Reactivate suspended user clears suspension and logs audit', () async {
      final suspendedUser = adminProvider.managedUsers.firstWhere((u) => u.isSuspended);

      final success = await adminProvider.reactivateUser(
        userId: suspendedUser.id,
        adminId: 'admin-super-01',
        isAdmin: true,
      );

      expect(success, isTrue);
      final updatedUser = adminProvider.managedUsers.firstWhere((u) => u.id == suspendedUser.id);
      expect(updatedUser.isSuspended, isFalse);
      expect(updatedUser.suspensionReason, isNull);

      final latestAudit = adminProvider.auditLogs.first;
      expect(latestAudit.action, 'USER_ACCOUNT_REACTIVATED');
      expect(latestAudit.targetId, suspendedUser.id);
    });

    test('Resolve and dismiss complaints updates status and records audit', () async {
      final openComplaint = adminProvider.complaints.firstWhere((c) => c.status == ComplaintStatus.open);

      final resolveSuccess = await adminProvider.resolveComplaint(
        complaintId: openComplaint.id,
        resolutionNotes: 'Packaging requirements communicated to donor; verified compliance.',
        adminId: 'admin-super-01',
        isAdmin: true,
      );

      expect(resolveSuccess, isTrue);
      final updatedComplaint = adminProvider.complaints.firstWhere((c) => c.id == openComplaint.id);
      expect(updatedComplaint.status, ComplaintStatus.resolved);
      expect(updatedComplaint.resolutionNotes, contains('Packaging requirements'));

      final latestAudit = adminProvider.auditLogs.first;
      expect(latestAudit.action, 'COMPLAINT_RESOLVED');
      expect(latestAudit.targetId, openComplaint.id);

      final dismissSuccess = await adminProvider.dismissComplaint(
        complaintId: updatedComplaint.id,
        reason: 'Duplicate complaint filed in error',
        adminId: 'admin-super-01',
        isAdmin: true,
      );

      expect(dismissSuccess, isTrue);
      final dismissed = adminProvider.complaints.firstWhere((c) => c.id == openComplaint.id);
      expect(dismissed.status, ComplaintStatus.dismissed);
    });

    test('Database-backed analytics compute strictly real dynamic aggregates (no fabrication)', () {
      final now = DateTime.now();
      final mockDonations = [
        Donation(
          id: 'mock-1',
          donorId: 'd1',
          donorName: 'Donor 1',
          title: 'Meals',
          description: 'Desc',
          type: DonationType.food,
          quantity: 25.0,
          unit: 'servings',
          status: DonationStatus.completed,
          claimedByNgoId: 'ngo-alpha',
          assignedVolunteerId: 'vol-bravo',
          pickupAddress: 'Area 1',
          pickupDeadline: now.add(const Duration(hours: 4)),
          createdAt: now,
        ),
        Donation(
          id: 'mock-2',
          donorId: 'd2',
          donorName: 'Donor 2',
          title: 'Warm Clothes',
          description: 'Desc',
          type: DonationType.clothing,
          quantity: 10.0,
          unit: 'items',
          status: DonationStatus.deliveredToNgo,
          claimedByNgoId: 'ngo-alpha',
          assignedVolunteerId: 'vol-bravo',
          pickupAddress: 'Area 2',
          pickupDeadline: now.add(const Duration(hours: 4)),
          createdAt: now,
        ),
        Donation(
          id: 'mock-3',
          donorId: 'd3',
          donorName: 'Donor 3',
          title: 'Vegetables',
          description: 'Desc',
          type: DonationType.food,
          quantity: 15.0,
          unit: 'kg',
          status: DonationStatus.available,
          pickupAddress: 'Area 3',
          pickupDeadline: now.add(const Duration(hours: 4)),
          createdAt: now,
        ),
      ];

      final analytics = adminProvider.computeAnalytics(mockDonations);

      expect(analytics['totalDonations'], 3);
      expect(analytics['foodDonations'], 2);
      expect(analytics['clothingDonations'], 1);
      expect(analytics['completedDonations'], 1);
      expect(analytics['successfulDeliveries'], 2); // 1 completed + 1 delivered
      expect(analytics['totalMealsRescued'], 25.0);
      expect(analytics['totalClothingItems'], 10);
      expect(analytics['activeNgos'], 1);
      expect(analytics['activeVolunteers'], 1);
    });
  });
}
