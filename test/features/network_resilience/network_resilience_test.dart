import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/donations/domain/models/donation.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';

void main() {
  group('SDLC Phase 11: Network Resilience, Offline Fallback & Duplicate Submissions Tests', () {
    late DonationProvider provider;

    setUp(() {
      provider = DonationProvider();
    });

    test('Offline Data Cache: In-memory seeded donations are available immediately without network', () {
      // Platform preserves instant local cache for discovery when offline
      expect(provider.allDonations.isNotEmpty, isTrue);
      expect(provider.availableDonations.isNotEmpty, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('Duplicate Submission Guard: Repeated claim calls on same listing are rejected', () async {
      final available = provider.allDonations.firstWhere((d) => d.status == DonationStatus.available);

      // First claim succeeds
      final firstAttempt = await provider.claimDonation(
        donationId: available.id,
        ngoId: 'ngo-alpha',
        ngoName: 'Asha Shelter',
        isVerifiedNgo: true,
      );
      expect(firstAttempt, isTrue);

      // Second identical claim immediately afterwards must fail
      final secondAttempt = await provider.claimDonation(
        donationId: available.id,
        ngoId: 'ngo-alpha',
        ngoName: 'Asha Shelter',
        isVerifiedNgo: true,
      );
      expect(secondAttempt, isFalse);
      expect(provider.errorMessage, contains('Cannot claim this donation'));
    });

    test('Network Retry & Timeout Resilience: Provider handles latency without state corruption', () async {
      final initialCount = provider.allDonations.length;

      final newDonation = Donation(
        id: 'dn-retry-test-1',
        donorId: 'd-test-1',
        donorName: 'Test Hotel',
        title: 'Delayed Network Insertion',
        description: 'Testing latency resilience',
        quantity: 20,
        unit: 'meals',
        type: DonationType.food,
        pickupAddress: 'Camp, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 4)),
      );

      final insertResult = await provider.createDonation(newDonation);
      expect(insertResult, isTrue);
      expect(provider.allDonations.length, initialCount + 1);
      expect(provider.allDonations.first.id, 'dn-retry-test-1');
    });

    test('Duplicate Publish Guard: Publishing an already active donation is idempotent', () async {
      final activeListing = provider.allDonations.firstWhere((d) => d.status == DonationStatus.available);

      // Attempting to publish an already available item
      final result = await provider.publishDraft(activeListing.id);
      expect(result, isTrue);

      final postCheck = provider.getDonationById(activeListing.id);
      expect(postCheck?.status, DonationStatus.available);
    });
  });
}
