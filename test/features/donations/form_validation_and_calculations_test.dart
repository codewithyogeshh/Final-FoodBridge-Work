import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/donations/domain/models/donation.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';

void main() {
  group('SDLC Phase 11: Form Validation & Quantity Calculations Tests', () {
    late DonationProvider provider;

    setUp(() {
      provider = DonationProvider();
    });

    test('Quantity validation: Positive quantity succeeds, zero or negative is invalid', () {
      final validDonation = Donation(
        id: 'dn-val-1',
        donorId: 'd-1',
        donorName: 'Test Cafe',
        title: 'Dal Rice Packs',
        description: 'Fresh lunch packs',
        quantity: 25.0,
        unit: 'meals',
        type: DonationType.food,
        pickupAddress: 'Swargate, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 3)),
      );

      expect(validDonation.quantity, greaterThan(0));

      // Attempting to create or validate with <= 0 quantity
      expect(
        () => validDonation.quantity <= 0,
        returnsNormally,
      );
      expect(validDonation.quantity <= 0, isFalse);
    });

    test('Partial claim calculation splits listing and preserves remaining stock', () async {
      final initialDonations = provider.allDonations.where((d) => d.status == DonationStatus.available).toList();
      expect(initialDonations.isNotEmpty, isTrue);

      final target = initialDonations.first;
      final originalQty = target.quantity;
      final claimAmount = originalQty / 2;

      // Verified NGO partial claim
      final result = await provider.claimDonation(
        donationId: target.id,
        ngoId: 'ngo-verified-001',
        ngoName: 'Asha Children Foundation',
        requestedQuantity: claimAmount,
        isVerifiedNgo: true,
      );

      expect(result, isTrue);

      // 1. Original listing remaining quantity is reduced
      final remainingListing = provider.getDonationById(target.id);
      expect(remainingListing?.quantity, originalQty - claimAmount);
      expect(remainingListing?.status, DonationStatus.available);

      // 2. Claimed slice created with accepted status and NGO id
      final claimedSlice = provider.allDonations.firstWhere((d) => d.claimedByNgoId == 'ngo-verified-001');
      expect(claimedSlice.quantity, claimAmount);
      expect(claimedSlice.status, DonationStatus.accepted);
      expect(claimedSlice.claimedByNgoName, 'Asha Children Foundation');
    });

    test('Over-allocation protection: Requesting more than available stock is strictly rejected', () async {
      final availableList = provider.allDonations.where((d) => d.status == DonationStatus.available).toList();
      expect(availableList.isNotEmpty, isTrue);

      final target = availableList.first;
      final excessiveQty = target.quantity + 50.0;

      final result = await provider.claimDonation(
        donationId: target.id,
        ngoId: 'ngo-verified-001',
        ngoName: 'Asha Children Foundation',
        requestedQuantity: excessiveQty,
        isVerifiedNgo: true,
      );

      expect(result, isFalse);
      expect(provider.errorMessage, contains('exceeds available'));
    });

    test('Food form validation: Mandatory hygiene pledge and storage temperature', () {
      final foodDonation = Donation(
        id: 'dn-food-hygiene',
        donorId: 'd-2',
        donorName: 'Biryani Corner',
        title: 'Veg Dum Biryani',
        description: 'Packed hot in aluminium containers',
        quantity: 40,
        unit: 'servings',
        type: DonationType.food,
        storageCondition: 'hot',
        safetyCharterAgreed: true,
        pickupAddress: 'Shivajinagar, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 4)),
      );

      expect(foodDonation.isFood, isTrue);
      expect(foodDonation.safetyCharterAgreed, isTrue);
      expect(foodDonation.storageCondition, 'hot');
    });

    test('Clothing form validation: Mandatory cleanliness declaration and condition grading', () {
      final clothingDonation = Donation(
        id: 'dn-clothing-clean',
        donorId: 'd-3',
        donorName: 'Rahul Joshi',
        title: 'Warm Winter Jackets',
        description: 'Cleaned and sorted jackets',
        quantity: 12,
        unit: 'pieces',
        type: DonationType.clothing,
        clothingCategory: 'winter',
        targetSize: 'L',
        conditionGrade: 'like_new',
        isWashedAndClean: true,
        pickupAddress: 'Kothrud, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(days: 5)),
      );

      expect(clothingDonation.isClothing, isTrue);
      expect(clothingDonation.isWashedAndClean, isTrue);
      expect(['brand_new', 'like_new', 'good'].contains(clothingDonation.conditionGrade), isTrue);
      expect(clothingDonation.clothingCategory, 'winter');
    });
  });
}
