import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/core/services/ai_service.dart';
import 'package:foodbridge/features/donations/domain/models/donation.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';

void main() {
  group('Volunteer Pickup-to-Handover Complete Journey Tests (SDLC Phase 8)', () {
    late DonationProvider provider;
    late AIService aiService;

    setUp(() {
      provider = DonationProvider();
      aiService = AIService();
    });

    test('1. Task Discovery: Available task displays route, distance, urgency, and AI smart match', () {
      final task = provider.volunteerAvailableTasks.first;

      // Verification of task discovery metadata
      expect(task.id, isNotEmpty);
      expect(task.title, isNotEmpty);
      expect(task.quantity, greaterThan(0));
      expect(task.unit, isNotEmpty);
      expect(task.city, isNotEmpty);
      expect(task.estimatedDistanceKm, greaterThan(0));
      expect(task.status, DonationStatus.claimed); // Claimed by NGO, ready for volunteer

      // AI Match metadata
      final match = aiService.calculateMatch(donation: task, distanceKm: task.estimatedDistanceKm);
      expect(match.matchScorePercent, inInclusiveRange(50, 99));
      expect(match.matchTier, isNotEmpty);
      expect(match.reason, isNotEmpty);
    });

    test('2. Task Acceptance & 2-Task Concurrent Limit Enforcement', () async {
      // Ensure at least 2 claimed donations are available for dispatch
      if (provider.volunteerAvailableTasks.length < 2) {
        final itemToClaim = provider.availableDonations.first;
        await provider.claimDonation(
          donationId: itemToClaim.id,
          ngoId: 'ngo-test-prep',
          ngoName: 'Asha Children Foundation',
        );
      }
      final available = provider.volunteerAvailableTasks;
      expect(available.length, greaterThanOrEqualTo(2));

      final task1 = available[0];
      final task2 = available[1];

      const volunteerId = 'vol-rider-42';
      const volunteerName = 'Karan Patel';

      // Accept 1st task
      final accept1 = await provider.acceptVolunteerTask(
        donationId: task1.id,
        volunteerId: volunteerId,
        volunteerName: volunteerName,
        phone: '+91 98811 22334',
      );
      expect(accept1, isTrue);

      final activeAfter1 = provider.getVolunteerActiveTasks(volunteerId);
      expect(activeAfter1.length, 1);
      expect(activeAfter1.first.id, task1.id);
      expect(activeAfter1.first.status, DonationStatus.assigned);
      expect(activeAfter1.first.assignedVolunteerId, volunteerId);

      // Accept 2nd task (up to limit)
      final accept2 = await provider.acceptVolunteerTask(
        donationId: task2.id,
        volunteerId: volunteerId,
        volunteerName: volunteerName,
      );
      expect(accept2, isTrue);

      final activeAfter2 = provider.getVolunteerActiveTasks(volunteerId);
      expect(activeAfter2.length, 2);

      // Attempt 3rd task acceptance -> Must be rejected by safety rule
      final freshTask3 = Donation(
        id: 'dn-extra-3',
        donorId: 'd-3',
        donorName: 'Caterer X',
        title: '3rd Surplus Task',
        description: 'Extra items',
        quantity: 10,
        unit: 'meals',
        type: DonationType.food,
        status: DonationStatus.claimed,
        pickupAddress: 'Viman Nagar, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 3)),
      );
      await provider.createDonation(freshTask3);

      final accept3 = await provider.acceptVolunteerTask(
        donationId: 'dn-extra-3',
        volunteerId: volunteerId,
        volunteerName: volunteerName,
      );
      expect(accept3, isFalse);
      expect(provider.errorMessage, contains('Maximum concurrent dispatch limit'));
      // Active tasks count remains 2
      expect(provider.getVolunteerActiveTasks(volunteerId).length, 2);
    });

    test('3. Task Execution: Donor OTP Pickup -> In-Transit Status -> NGO OTP Handover', () async {
      final task = provider.volunteerAvailableTasks.first;
      const volunteerId = 'vol-journey-hero';

      // 1. Accept
      await provider.acceptVolunteerTask(
        donationId: task.id,
        volunteerId: volunteerId,
        volunteerName: 'Vikram Joshi',
      );

      final assigned = provider.getDonationById(task.id)!;
      expect(assigned.status, DonationStatus.assigned);

      // 2. Physical Pickup with wrong OTP -> Rejected
      final wrongPickup = await provider.confirmPickupWithOtp(
        donationId: task.id,
        enteredOtp: '9999',
      );
      expect(wrongPickup, isFalse);
      expect(provider.errorMessage, contains('Invalid Donor Pickup Verification Code'));
      expect(provider.getDonationById(task.id)!.status, DonationStatus.assigned);

      // 3. Physical Pickup with correct OTP -> Enters In-Transit
      final correctPickup = await provider.confirmPickupWithOtp(
        donationId: task.id,
        enteredOtp: assigned.pickupOtp,
      );
      expect(correctPickup, isTrue);

      final inTransit = provider.getDonationById(task.id)!;
      expect(inTransit.status, DonationStatus.pickedUp);
      expect(inTransit.pickedUpAt, isNotNull);

      // 4. Physical Handover at NGO shelter with wrong OTP -> Rejected
      final wrongDelivery = await provider.confirmDeliveryWithOtp(
        donationId: task.id,
        enteredOtp: '1111',
      );
      expect(wrongDelivery, isFalse);
      expect(provider.errorMessage, contains('Invalid NGO Handover Verification Code'));
      expect(provider.getDonationById(task.id)!.status, DonationStatus.pickedUp);

      // 5. Physical Handover at NGO shelter with correct OTP -> Completed Delivery
      final correctDelivery = await provider.confirmDeliveryWithOtp(
        donationId: task.id,
        enteredOtp: inTransit.deliveryOtp,
      );
      expect(correctDelivery, isTrue);

      final delivered = provider.getDonationById(task.id)!;
      expect(delivered.status, DonationStatus.delivered);
      expect(delivered.deliveredAt, isNotNull);

      // Volunteer active tasks now cleared
      expect(provider.getVolunteerActiveTasks(volunteerId).length, 0);
      // Completed missions incremented
      expect(provider.getVolunteerCompletedTasks(volunteerId).length, 1);
    });

    test('4. Safety & Exception Handling: Reassignment and cancellation releases task back to pool', () async {
      final task = provider.volunteerAvailableTasks.first;
      const volunteerId = 'vol-breakdown-1';

      await provider.acceptVolunteerTask(
        donationId: task.id,
        volunteerId: volunteerId,
        volunteerName: 'Rider In Trouble',
      );

      // Rider encounters motorcycle breakdown
      final cancelSuccess = await provider.cancelVolunteerTask(
        donationId: task.id,
        reason: 'Vehicle Breakdown / Flat Tire - Near Deccan Gymkhana',
      );
      expect(cancelSuccess, isTrue);

      final released = provider.getDonationById(task.id)!;
      // Status returned to claimed so other riders can see it
      expect(released.status, DonationStatus.claimed);
      expect(released.assignedVolunteerId, isNull);
      expect(released.assignedVolunteerName, isNull);

      // Available tasks includes the released task again
      expect(provider.volunteerAvailableTasks.any((d) => d.id == task.id), isTrue);

      // Another rider can immediately pick it up
      final reassignSuccess = await provider.acceptVolunteerTask(
        donationId: task.id,
        volunteerId: 'vol-replacement-2',
        volunteerName: 'Nearby Replacement Rider',
      );
      expect(reassignSuccess, isTrue);
      expect(provider.getDonationById(task.id)!.assignedVolunteerId, 'vol-replacement-2');
    });
  });
}
