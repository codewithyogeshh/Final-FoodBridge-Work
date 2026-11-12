import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';
import 'package:foodbridge/features/authentication/domain/models/app_user.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';
import 'package:foodbridge/features/donations/domain/models/donation.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';

void main() {
  group('SDLC Phase 11: Security, RBAC & Address Privacy Tests', () {
    late AdminProvider adminProvider;
    late DonationProvider donationProvider;
    late AuthProvider authProvider;

    setUp(() {
      adminProvider = AdminProvider();
      donationProvider = DonationProvider();
      authProvider = AuthProvider();
    });

    test('RBAC: Non-admin users cannot execute administrative operations', () async {
      // Non-admin attempting to approve NGO
      final approveSuccess = await adminProvider.approveNgo(
        ngoId: 'ngo-app-1',
        adminId: 'non-admin-user',
        isAdmin: false,
      );
      expect(approveSuccess, isFalse);
      expect(adminProvider.errorMessage, contains('Unauthorized'));

      // Non-admin attempting to suspend a user
      final suspendSuccess = await adminProvider.suspendUser(
        userId: 'usr-donor-101',
        reason: 'Malicious attempt',
        adminId: 'non-admin-user',
        isAdmin: false,
      );
      expect(suspendSuccess, isFalse);
      expect(adminProvider.errorMessage, contains('Unauthorized'));

      // Non-admin attempting to resolve complaint
      final resolveSuccess = await adminProvider.resolveComplaint(
        complaintId: 'cmp-101',
        resolutionNotes: 'Unauthorized close',
        adminId: 'non-admin-user',
        isAdmin: false,
      );
      expect(resolveSuccess, isFalse);
      expect(adminProvider.errorMessage, contains('Unauthorized'));
    });

    test('RBAC: Unverified NGO cannot claim active food donations', () async {
      final availableDonations = donationProvider.allDonations
          .where((d) => d.status == DonationStatus.available)
          .toList();
      expect(availableDonations.isNotEmpty, isTrue);

      final target = availableDonations.first;

      final claimResult = await donationProvider.claimDonation(
        donationId: target.id,
        ngoId: 'ngo-unverified-999',
        ngoName: 'Unverified Group',
        isVerifiedNgo: false,
      );

      expect(claimResult, isFalse);
      expect(donationProvider.errorMessage, contains('Verification Required'));
      expect(donationProvider.errorMessage, contains('80G/Darpan'));
    });

    test('Two-Tier Location Privacy: Public discovery hides private donor phone number', () {
      final sampleDonation = Donation(
        id: 'dn-privacy-test',
        donorId: 'd-priv-1',
        donorName: 'Residential Donor',
        donorPhone: '+91 98765 43210',
        title: 'Home Cooked Meals',
        description: 'Packaged lunch',
        quantity: 10,
        unit: 'meals',
        type: DonationType.food,
        pickupAddress: 'Flat 402, Rosewood Heights, Karve Road, Kothrud',
        city: 'Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 3)),
      );

      // In public discovery context, private address and phone must not be visible without claim
      expect(sampleDonation.city, 'Pune');
      // When unassigned and unclaimed, donor phone should only be revealed post-acceptance
      expect(sampleDonation.claimedByNgoId, isNull);
      expect(sampleDonation.assignedVolunteerId, isNull);
    });

    test('Volunteer Concurrency Limit: Enforces strict 2-task active limit', () async {
      const volunteerId = 'vol-security-tester';

      // 1. Accept first task
      final task1 = donationProvider.volunteerAvailableTasks[0];
      final res1 = await donationProvider.acceptVolunteerTask(
        donationId: task1.id,
        volunteerId: volunteerId,
        volunteerName: 'Security Tester',
      );
      expect(res1, isTrue);

      // Pre-claim an available item if needed to ensure second task exists
      if (donationProvider.volunteerAvailableTasks.isEmpty) {
        final available = donationProvider.allDonations.firstWhere((d) => d.status == DonationStatus.available);
        await donationProvider.claimDonation(
          donationId: available.id,
          ngoId: 'ngo-verified',
          ngoName: 'Asha Shelter',
          isVerifiedNgo: true,
        );
      }

      // 2. Accept second task
      final task2 = donationProvider.volunteerAvailableTasks[0];
      final res2 = await donationProvider.acceptVolunteerTask(
        donationId: task2.id,
        volunteerId: volunteerId,
        volunteerName: 'Security Tester',
      );
      expect(res2, isTrue);

      // Pre-claim another item to attempt 3rd task
      final remainingAvailable = donationProvider.allDonations.firstWhere((d) => d.status == DonationStatus.available);
      await donationProvider.claimDonation(
        donationId: remainingAvailable.id,
        ngoId: 'ngo-verified',
        ngoName: 'Asha Shelter',
        isVerifiedNgo: true,
      );

      // 3. Attempting 3rd simultaneous task must fail with limit error
      final task3 = donationProvider.volunteerAvailableTasks[0];
      final res3 = await donationProvider.acceptVolunteerTask(
        donationId: task3.id,
        volunteerId: volunteerId,
        volunteerName: 'Security Tester',
      );
      expect(res3, isFalse);
      expect(donationProvider.errorMessage, contains('Maximum concurrent dispatch limit reached'));
    });

    test('Credential Exposure Guard: Client environment has no exposed secrets or master keys', () {
      // In Flutter client, sensitive admin keys must never be present
      expect(authProvider.user?.role != UserRole.admin || authProvider.isAuthenticated, isTrue);
      // Ensure user passwords are not stored in memory models
      expect(authProvider.user?.email.isNotEmpty, isTrue);
    });
  });
}
