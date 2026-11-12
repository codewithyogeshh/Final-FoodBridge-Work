import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/donations/domain/models/donation.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';

void main() {
  group('SDLC Phase 11: Donation Lifecycle & Food Safety Transitions Tests', () {
    late DonationProvider provider;

    setUp(() {
      provider = DonationProvider();
    });

    test('All 12 DonationStatus values are defined and have user-facing display names', () {
      expect(DonationStatus.values.length, 12);
      for (final status in DonationStatus.values) {
        expect(status.displayName.isNotEmpty, isTrue);
      }
    });

    test('Valid lifecycle forward transitions from draft to completed succeed', () {
      expect(DonationStatus.draft.canTransitionTo(DonationStatus.available), isTrue);
      expect(DonationStatus.available.canTransitionTo(DonationStatus.requested), isTrue);
      expect(DonationStatus.available.canTransitionTo(DonationStatus.accepted), isTrue);
      expect(DonationStatus.requested.canTransitionTo(DonationStatus.accepted), isTrue);
      expect(DonationStatus.accepted.canTransitionTo(DonationStatus.assignedForPickup), isTrue);
      expect(DonationStatus.accepted.canTransitionTo(DonationStatus.pickedUp), isTrue);
      expect(DonationStatus.assignedForPickup.canTransitionTo(DonationStatus.pickedUp), isTrue);
      expect(DonationStatus.pickedUp.canTransitionTo(DonationStatus.deliveredToNgo), isTrue);
      expect(DonationStatus.deliveredToNgo.canTransitionTo(DonationStatus.distributed), isTrue);
      expect(DonationStatus.deliveredToNgo.canTransitionTo(DonationStatus.completed), isTrue);
      expect(DonationStatus.distributed.canTransitionTo(DonationStatus.completed), isTrue);
    });

    test('Invalid illegal lifecycle jumps are strictly rejected', () {
      // Cannot skip directly from draft to in-transit or delivered
      expect(DonationStatus.draft.canTransitionTo(DonationStatus.pickedUp), isFalse);
      expect(DonationStatus.draft.canTransitionTo(DonationStatus.deliveredToNgo), isFalse);
      expect(DonationStatus.draft.canTransitionTo(DonationStatus.completed), isFalse);

      // Terminal states cannot transition to any new state
      expect(DonationStatus.completed.canTransitionTo(DonationStatus.available), isFalse);
      expect(DonationStatus.cancelled.canTransitionTo(DonationStatus.available), isFalse);
      expect(DonationStatus.expired.canTransitionTo(DonationStatus.available), isFalse);
      expect(DonationStatus.rejected.canTransitionTo(DonationStatus.available), isFalse);
    });

    test('Food Safety: Expired donation transition and detection', () {
      expect(DonationStatus.available.canTransitionTo(DonationStatus.expired), isTrue);

      final pastDeadline = DateTime.now().subtract(const Duration(minutes: 30));
      final pastDeadlineDonation = Donation(
        id: 'dn-expired-time-test',
        donorId: 'd1',
        donorName: 'Catering Surplus',
        title: '50 Cooked Meals',
        description: 'Past safe pickup deadline',
        quantity: 50,
        unit: 'meals',
        type: DonationType.food,
        status: DonationStatus.available,
        pickupAddress: 'Swargate, Pune',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        pickupDeadline: pastDeadline,
      );

      expect(pastDeadlineDonation.timeRemaining.isNegative, isTrue);
      expect(pastDeadlineDonation.status.canTransitionTo(DonationStatus.expired), isTrue);

      final expiredStatusDonation = pastDeadlineDonation.copyWith(
        status: DonationStatus.expired,
      );
      expect(expiredStatusDonation.isExpired, isTrue);
    });

    test('Food Safety: Rejected donation when NGO inspection fails', () {
      expect(DonationStatus.requested.canTransitionTo(DonationStatus.rejected), isTrue);

      final donation = Donation(
        id: 'dn-reject-test',
        donorId: 'd2',
        donorName: 'Quick Bites',
        title: 'Damaged packaging curry boxes',
        description: 'Damaged containers observed upon inspection',
        quantity: 15,
        unit: 'meals',
        type: DonationType.food,
        status: DonationStatus.requested,
        pickupAddress: 'Kothrud, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 2)),
      );

      expect(donation.status.canTransitionTo(DonationStatus.rejected), isTrue);
      expect(DonationStatus.rejected.canTransitionTo(DonationStatus.available), isFalse);
    });

    test('Food Safety: Missing handling information or storage condition defaults to safe ambient', () {
      final donation = Donation(
        id: 'dn-ambient-default',
        donorId: 'd3',
        donorName: 'Bakery Surplus',
        title: 'Packaged Bread',
        description: 'No explicit storage condition provided',
        quantity: 20,
        unit: 'loaves',
        type: DonationType.food,
        pickupAddress: 'Hadapsar, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 5)),
      );

      // Default storage condition must be safely initialized
      expect(donation.storageCondition, 'ambient');
      expect(donation.safetyCharterAgreed, isTrue);
    });

    test('Emergency cancellation releases task back to dispatch pool', () async {
      // Find or create an in-transit/assigned task
      final claimedList = provider.allDonations
          .where((d) => d.status == DonationStatus.assignedForPickup || d.status == DonationStatus.accepted)
          .toList();

      if (claimedList.isNotEmpty) {
        final target = claimedList.first;
        final releaseSuccess = await provider.cancelVolunteerTask(
          donationId: target.id,
          reason: 'Volunteer vehicle breakdown on highway',
        );

        expect(releaseSuccess, isTrue);
        final updated = provider.getDonationById(target.id);
        expect(updated?.assignedVolunteerId, isNull);
        expect(updated?.status, DonationStatus.accepted);
      }
    });
  });
}
