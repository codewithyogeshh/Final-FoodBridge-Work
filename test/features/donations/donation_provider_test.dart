import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/donations/domain/models/donation.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';

void main() {
  group('DonationProvider Tests', () {
    late DonationProvider provider;

    setUp(() {
      provider = DonationProvider();
    });

    test('Initial state contains seeded active listings', () {
      expect(provider.allDonations.isNotEmpty, isTrue);
      expect(provider.availableDonations.isNotEmpty, isTrue);
      expect(provider.activeListingsCount, greaterThan(0));
    });

    test('Filter by donation type works', () {
      provider.setTypeFilter(DonationType.food);
      for (final d in provider.filteredDonations) {
        expect(d.type, DonationType.food);
      }

      provider.setTypeFilter(DonationType.clothing);
      for (final d in provider.filteredDonations) {
        expect(d.type, DonationType.clothing);
      }

      provider.setTypeFilter(null);
      expect(provider.filteredDonations.length, provider.allDonations.length);
    });

    test('Create donation inserts item at index 0', () async {
      final initialCount = provider.allDonations.length;
      final newDonation = Donation(
        id: 'test-dn-999',
        donorId: 'test-donor-1',
        donorName: 'Test Bistro',
        title: '20 Boxes of Fresh Pav Bhaji',
        description: 'Fresh surplus',
        quantity: 20,
        unit: 'meals',
        type: DonationType.food,
        pickupAddress: 'FC Road, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 3)),
      );

      final success = await provider.createDonation(newDonation);
      expect(success, isTrue);
      expect(provider.allDonations.length, initialCount + 1);
      expect(provider.allDonations.first.id, 'test-dn-999');
    });

    test('Full lifecycle: List -> Claim -> Assign -> PickUp -> Deliver', () async {
      // 1. Initial listing is available
      final item = provider.availableDonations.first;
      final itemId = item.id;
      expect(item.status, DonationStatus.listed);

      // 2. NGO claims donation
      final claimSuccess = await provider.claimDonation(
        donationId: itemId,
        ngoId: 'ngo-test-1',
        ngoName: 'Asha Shelter',
      );
      expect(claimSuccess, isTrue);
      final claimedItem = provider.getDonationById(itemId)!;
      expect(claimedItem.status, DonationStatus.claimed);
      expect(claimedItem.claimedByNgoId, 'ngo-test-1');

      // 3. Volunteer accepts task
      final acceptSuccess = await provider.acceptVolunteerTask(
        donationId: itemId,
        volunteerId: 'vol-test-1',
        volunteerName: 'Rahul Rider',
      );
      expect(acceptSuccess, isTrue);
      final assignedItem = provider.getDonationById(itemId)!;
      expect(assignedItem.status, DonationStatus.assigned);
      expect(assignedItem.assignedVolunteerId, 'vol-test-1');

      // 4. Volunteer marks picked up
      final pickupSuccess = await provider.markPickedUp(itemId);
      expect(pickupSuccess, isTrue);
      final inTransitItem = provider.getDonationById(itemId)!;
      expect(inTransitItem.status, DonationStatus.pickedUp);
      expect(inTransitItem.pickedUpAt, isNotNull);

      // 5. Volunteer marks delivered
      final deliverSuccess = await provider.markDelivered(itemId);
      expect(deliverSuccess, isTrue);
      final deliveredItem = provider.getDonationById(itemId)!;
      expect(deliveredItem.status, DonationStatus.delivered);
      expect(deliveredItem.deliveredAt, isNotNull);
    });

    test('Impact metrics calculation', () {
      expect(provider.totalMealsRescued, greaterThanOrEqualTo(0));
      expect(provider.totalClothingItemsRedistributed, greaterThanOrEqualTo(0));
    });

    test('Partial quantity claim splits surplus correctly', () async {
      // Create a donation of 50 meals
      final original = Donation(
        id: 'dn-partial-test',
        donorId: 'test-donor-1',
        donorName: 'Grand Hyatt',
        title: '50 Buffet Meals',
        description: 'Dal Makhani and Rice',
        quantity: 50,
        unit: 'meals',
        type: DonationType.food,
        pickupAddress: 'Viman Nagar, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 4)),
      );
      await provider.createDonation(original);

      // NGO claims 20 meals out of 50
      final success = await provider.claimDonation(
        donationId: 'dn-partial-test',
        ngoId: 'ngo-shelter-1',
        ngoName: 'Asha Shelter',
        requestedQuantity: 20,
      );

      expect(success, isTrue);

      // Original listing should now have 30 meals remaining and remain listed
      final updatedOriginal = provider.getDonationById('dn-partial-test')!;
      expect(updatedOriginal.quantity, 30.0);
      expect(updatedOriginal.status, DonationStatus.listed);

      // A new claimed slice of 20 meals should exist
      final claimedSlice = provider.allDonations.firstWhere(
        (d) => d.claimedByNgoId == 'ngo-shelter-1' && d.quantity == 20.0,
      );
      expect(claimedSlice.status, DonationStatus.claimed);
      expect(claimedSlice.claimedByNgoName, 'Asha Shelter');
      expect(claimedSlice.claimedAt, isNotNull);
    });

    test('Over-allocation claim is rejected with error message', () async {
      final original = Donation(
        id: 'dn-overalloc-test',
        donorId: 'test-donor-1',
        donorName: 'Bistro',
        title: '15 Sandwiches',
        description: 'Veg Sandwiches',
        quantity: 15,
        unit: 'meals',
        type: DonationType.food,
        pickupAddress: 'KP, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 2)),
      );
      await provider.createDonation(original);

      // NGO attempts to claim 30 when only 15 available
      final success = await provider.claimDonation(
        donationId: 'dn-overalloc-test',
        ngoId: 'ngo-shelter-1',
        ngoName: 'Asha Shelter',
        requestedQuantity: 30,
      );

      expect(success, isFalse);
      expect(provider.errorMessage, contains('exceeds available'));
      // Quantity should be untouched
      expect(provider.getDonationById('dn-overalloc-test')!.quantity, 15.0);
    });

    test('Donor can edit listed donation details', () async {
      final item = provider.availableDonations.first;
      final updated = item.copyWith(
        title: 'Updated Gourmet Biryani Boxes',
        quantity: 45,
        storageCondition: 'hot',
      );

      final success = await provider.updateDonation(updated);
      expect(success, isTrue);

      final retrieved = provider.getDonationById(item.id)!;
      expect(retrieved.title, 'Updated Gourmet Biryani Boxes');
      expect(retrieved.quantity, 45.0);
      expect(retrieved.storageCondition, 'hot');
    });

    test('Editing already claimed donation is prohibited', () async {
      // Find or claim a donation
      final item = provider.availableDonations.first;
      await provider.claimDonation(
        donationId: item.id,
        ngoId: 'ngo-1',
        ngoName: 'Shelter',
      );

      final claimedItem = provider.getDonationById(item.id)!;
      final attemptUpdate = claimedItem.copyWith(title: 'Hacked Title');

      final success = await provider.updateDonation(attemptUpdate);
      expect(success, isFalse);
      expect(provider.errorMessage, contains('Cannot edit donation after it has been claimed'));
    });

    test('Donor can withdraw an active listing', () async {
      final item = provider.availableDonations.first;
      final success = await provider.withdrawDonation(item.id);

      expect(success, isTrue);
      final withdrawn = provider.getDonationById(item.id)!;
      expect(withdrawn.status, DonationStatus.cancelled);
      expect(provider.availableDonations.any((d) => d.id == item.id), isFalse);
    });

    test('Veg and non-veg filtering works properly', () {
      provider.setVegFilter(true);
      for (final d in provider.filteredDonations.where((d) => d.isFood)) {
        expect(d.isVeg, isTrue);
      }

      provider.setVegFilter(false);
      for (final d in provider.filteredDonations.where((d) => d.isFood)) {
        expect(d.isVeg, isFalse);
      }

      provider.setVegFilter(null);
    });

    test('Volunteer can accept task up to limit of 2 concurrent dispatches', () async {
      // 1. Grab 3 available donations upfront before claiming
      final d1 = provider.availableDonations[0];
      final d2 = provider.availableDonations[1];
      final d3 = provider.availableDonations[2];

      await provider.claimDonation(
        donationId: d1.id,
        ngoId: 'ngo-shelter-1',
        ngoName: 'Asha Shelter',
      );
      await provider.claimDonation(
        donationId: d2.id,
        ngoId: 'ngo-shelter-1',
        ngoName: 'Asha Shelter',
      );

      // Volunteer accepts 1st task
      final accept1 = await provider.acceptVolunteerTask(
        donationId: d1.id,
        volunteerId: 'vol-test-99',
        volunteerName: 'Samir Rider',
      );
      expect(accept1, isTrue);

      // Volunteer accepts 2nd task
      final accept2 = await provider.acceptVolunteerTask(
        donationId: d2.id,
        volunteerId: 'vol-test-99',
        volunteerName: 'Samir Rider',
      );
      expect(accept2, isTrue);
      expect(provider.getVolunteerActiveTasks('vol-test-99').length, 2);

      // Claim 3rd task
      await provider.claimDonation(
        donationId: d3.id,
        ngoId: 'ngo-shelter-1',
        ngoName: 'Asha Shelter',
      );

      // Attempt to accept 3rd concurrent task should be blocked
      final accept3 = await provider.acceptVolunteerTask(
        donationId: d3.id,
        volunteerId: 'vol-test-99',
        volunteerName: 'Samir Rider',
      );
      expect(accept3, isFalse);
      expect(provider.errorMessage, contains('Maximum concurrent dispatch limit reached'));
    });

    test('OTP Verification: Incorrect code fails, correct code completes physical pickup', () async {
      final item = provider.availableDonations.first;
      await provider.claimDonation(
        donationId: item.id,
        ngoId: 'ngo-1',
        ngoName: 'Asha Shelter',
      );
      await provider.acceptVolunteerTask(
        donationId: item.id,
        volunteerId: 'vol-test-1',
        volunteerName: 'Rider',
      );

      // Entering wrong OTP fails
      final wrongPickup = await provider.confirmPickupWithOtp(
        donationId: item.id,
        enteredOtp: '0987',
      );
      expect(wrongPickup, isFalse);
      expect(provider.errorMessage, contains('Invalid Donor Pickup Verification Code'));

      // Entering correct OTP succeeds
      final correctOtp = provider.getDonationById(item.id)!.pickupOtp;
      final successPickup = await provider.confirmPickupWithOtp(
        donationId: item.id,
        enteredOtp: correctOtp,
      );
      expect(successPickup, isTrue);

      final inTransit = provider.getDonationById(item.id)!;
      expect(inTransit.status, DonationStatus.pickedUp);
      expect(inTransit.pickedUpAt, isNotNull);
    });

    test('NGO Handover OTP: Verifies and completes mission', () async {
      final item = provider.availableDonations.first;
      await provider.claimDonation(
        donationId: item.id,
        ngoId: 'ngo-1',
        ngoName: 'Asha Shelter',
      );
      await provider.acceptVolunteerTask(
        donationId: item.id,
        volunteerId: 'vol-test-1',
        volunteerName: 'Rider',
      );
      await provider.markPickedUp(item.id);

      // Wrong delivery code
      final wrongDelivery = await provider.confirmDeliveryWithOtp(
        donationId: item.id,
        enteredOtp: '1111',
      );
      expect(wrongDelivery, isFalse);
      expect(provider.errorMessage, contains('Invalid NGO Handover Verification Code'));

      // Correct delivery code
      final deliveryOtp = provider.getDonationById(item.id)!.deliveryOtp;
      final successDelivery = await provider.confirmDeliveryWithOtp(
        donationId: item.id,
        enteredOtp: deliveryOtp,
      );
      expect(successDelivery, isTrue);

      final delivered = provider.getDonationById(item.id)!;
      expect(delivered.status, DonationStatus.delivered);
      expect(delivered.deliveredAt, isNotNull);
    });

    test('Volunteer emergency cancellation releases task back to dispatch pool', () async {
      final item = provider.availableDonations.first;
      await provider.claimDonation(
        donationId: item.id,
        ngoId: 'ngo-1',
        ngoName: 'Asha Shelter',
      );
      await provider.acceptVolunteerTask(
        donationId: item.id,
        volunteerId: 'vol-breakdown',
        volunteerName: 'Breakdown Rider',
      );

      // Volunteer cancels due to vehicle breakdown
      final cancelSuccess = await provider.cancelVolunteerTask(
        donationId: item.id,
        reason: 'Motorcycle flat tire',
      );
      expect(cancelSuccess, isTrue);

      final released = provider.getDonationById(item.id)!;
      expect(released.status, DonationStatus.claimed);
      expect(released.assignedVolunteerId, isNull);
      expect(released.assignedVolunteerName, isNull);

      // Task is now back in available tasks for other volunteers
      expect(provider.volunteerAvailableTasks.any((d) => d.id == item.id), isTrue);
    });
  });
}

