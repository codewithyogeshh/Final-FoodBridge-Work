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
  });
}

