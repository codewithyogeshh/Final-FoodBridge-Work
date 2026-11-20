import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/donations/domain/models/donation.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';

void main() {
  group('Cross-Role Real-Time Sync & Zero-Dummy Integration Test', () {
    late DonationProvider provider;

    setUp(() {
      provider = DonationProvider();
    });

    test('Full Multi-Role Sync Flow: Donor -> NGO Claim -> Volunteer Dispatch -> Handover', () async {
      // 1. Purge any dummy data
      provider.allDonations;

      // 2. Donor posts a real donation
      final realDonation = Donation(
        id: 'real-food-satara-001',
        donorId: 'donor-sam-101',
        donorName: 'Samruddhi Sawant',
        donorPhone: '7498855751',
        title: '50 Fresh Tiffin Boxes',
        description: 'Fresh homemade meals, packaged hygienically.',
        quantity: 50,
        unit: 'meals',
        type: DonationType.food,
        status: DonationStatus.available,
        pickupAddress: 'Sadar Bazar, Satara',
        city: 'Satara',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 4)),
        pickupOtp: '4829',
        deliveryOtp: '9152',
        isVeg: true,
      );

      final created = await provider.createDonation(realDonation);
      expect(created, isTrue);

      // Verify Donor sees it
      final donorDonations = provider.getDonationsByDonor('donor-sam-101');
      expect(donorDonations.any((d) => d.id == 'real-food-satara-001'), isTrue);

      // Verify NGO sees it in Available Listings
      expect(provider.availableDonations.any((d) => d.id == 'real-food-satara-001'), isTrue);

      // Verify Volunteer does NOT see it yet (because NGO hasn't claimed it yet)
      expect(provider.volunteerAvailableTasks.any((d) => d.id == 'real-food-satara-001'), isFalse);

      // 3. NGO (Kbp NGO) claims the donation
      final claimed = await provider.claimDonation(
        donationId: 'real-food-satara-001',
        ngoId: 'ngo-kbp-777',
        ngoName: 'Kbp NGO Shelter',
        isVerifiedNgo: true,
      );
      expect(claimed, isTrue);

      // Verify NGO sees it in their claimed list
      final ngoClaims = provider.getDonationsClaimedByNgo('ngo-kbp-777');
      expect(ngoClaims.any((d) => d.id == 'real-food-satara-001'), isTrue);

      // Verify it is REMOVED from available feed (no duplicate claims)
      expect(provider.availableDonations.any((d) => d.id == 'real-food-satara-001'), isFalse);

      // 4. Volunteer immediately sees it in Available Tasks
      expect(provider.volunteerAvailableTasks.any((d) => d.id == 'real-food-satara-001'), isTrue);

      // 5. Volunteer accepts the task
      final accepted = await provider.acceptVolunteerTask(
        donationId: 'real-food-satara-001',
        volunteerId: 'vol-rahul-99',
        volunteerName: 'Rahul Patil',
        phone: '9822011223',
      );
      expect(accepted, isTrue);

      // Verify Volunteer active tasks contains it
      final volActive = provider.getVolunteerActiveTasks('vol-rahul-99');
      expect(volActive.any((d) => d.id == 'real-food-satara-001'), isTrue);

      // 6. Volunteer verifies Donor OTP at pickup location
      final targetItem = provider.getDonationById('real-food-satara-001')!;
      final pickupSuccess = await provider.confirmPickupWithOtp(
        donationId: 'real-food-satara-001',
        enteredOtp: targetItem.pickupOtp,
      );
      expect(pickupSuccess, isTrue);

      final inTransit = provider.getDonationById('real-food-satara-001');
      expect(inTransit?.status, DonationStatus.pickedUp);

      // 7. Volunteer verifies NGO Handover OTP at shelter
      final deliverySuccess = await provider.confirmDeliveryWithOtp(
        donationId: 'real-food-satara-001',
        enteredOtp: inTransit!.deliveryOtp,
      );
      expect(deliverySuccess, isTrue);

      // 8. Verify Completed & Rescued Meals
      final volCompleted = provider.getVolunteerCompletedTasks('vol-rahul-99');
      expect(volCompleted.any((d) => d.id == 'real-food-satara-001'), isTrue);
      expect(provider.totalMealsRescued, greaterThanOrEqualTo(50));

      // 9. Verify Dummy Data Exclusion
      expect(DonationProvider.isDummyDonation(realDonation), isFalse);
    });
  });
}
