import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/core/services/ai_service.dart';
import 'package:foodbridge/features/donations/domain/models/donation.dart';

void main() {
  group('AIService Tests - SDLC Phase 8 & Architecture Section 8', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('calculateMatch returns high match score for close-proximity urgent food', () {
      final urgentFood = Donation(
        id: 'dn-ai-1',
        donorId: 'd-1',
        donorName: 'Test Cafe',
        title: '30 Hot Meal Boxes',
        description: 'Fresh lunch packs',
        quantity: 30,
        unit: 'meals',
        type: DonationType.food,
        pickupAddress: 'Camp, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 2)), // Urgent < 3 hrs
        isVeg: true,
        storageCondition: 'hot',
        estimatedDistanceKm: 2.1,
      );

      final match = aiService.calculateMatch(
        donation: urgentFood,
        distanceKm: 2.1,
      );

      expect(match.matchScorePercent, greaterThanOrEqualTo(90));
      expect(match.isHighPriority, isTrue);
      expect(match.matchTier, contains('High Match'));
      expect(match.reason, contains('proximity'));
      expect(match.reason, contains('Expiring soon'));
    });

    test('calculateMatch adjusts score for extended transit distance', () {
      final distantDonation = Donation(
        id: 'dn-ai-2',
        donorId: 'd-2',
        donorName: 'Far Away Bakery',
        title: '15 Bread Loaves',
        description: 'Day-end bakery surplus',
        quantity: 15,
        unit: 'loaves',
        type: DonationType.food,
        pickupAddress: 'Wakad, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 8)),
        estimatedDistanceKm: 12.5,
      );

      final match = aiService.calculateMatch(
        donation: distantDonation,
        distanceKm: 12.5,
      );

      expect(match.matchScorePercent, lessThan(85));
      expect(match.reason, contains('Extended transit'));
    });

    test('getSafeHandlingAdvisory: Hot food recommends thermal container and transit window', () {
      final hotFood = Donation(
        id: 'dn-hot',
        donorId: 'd-hot',
        donorName: 'Bistro Biryani',
        title: '40 Hot Dum Biryani Trays',
        description: 'Sealed foil trays',
        quantity: 40,
        unit: 'meals',
        type: DonationType.food,
        storageCondition: 'hot',
        allergenNotes: 'Contains Dairy & Cashews',
        pickupAddress: 'FC Road, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 3)),
      );

      final advisory = aiService.getSafeHandlingAdvisory(hotFood);

      expect(advisory.title, contains('Hot Food'));
      expect(advisory.recommendedContainer, contains('Thermal'));
      expect(advisory.handlingTips.any((t) => t.contains('>60°C')), isTrue);
      expect(advisory.handlingTips.any((t) => t.contains('Allergens: Contains Dairy & Cashews')), isTrue);
      // Rule 14 Compliance: AI must never certify food safety
      expect(advisory.disclaimer, contains('does not certify food safety'));
    });

    test('getSafeHandlingAdvisory: Cold storage food recommends cooler box and ice-packs', () {
      final coldFood = Donation(
        id: 'dn-cold',
        donorId: 'd-cold',
        donorName: 'Dairy Direct',
        title: '20 Milk and Paneer Packets',
        description: 'Chilled dairy surplus',
        quantity: 20,
        unit: 'packets',
        type: DonationType.food,
        storageCondition: 'chilled',
        pickupAddress: 'Swargate, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(hours: 4)),
      );

      final advisory = aiService.getSafeHandlingAdvisory(coldFood);

      expect(advisory.title, contains('Cold Storage'));
      expect(advisory.recommendedContainer, contains('Cooler'));
      expect(advisory.handlingTips.any((t) => t.contains('<8°C')), isTrue);
      // Rule 14 Compliance check
      expect(advisory.disclaimer, contains('does not certify food safety'));
    });

    test('getSafeHandlingAdvisory: Clothing recommends rain protection and dry handling', () {
      final clothes = Donation(
        id: 'dn-cloth',
        donorId: 'd-cloth',
        donorName: 'Generous Donor',
        title: '30 Clean Blankets',
        description: 'Washed and packed in plastic',
        quantity: 30,
        unit: 'pieces',
        type: DonationType.clothing,
        clothingCategory: 'Blankets & Quilts',
        pickupAddress: 'Kothrud, Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(days: 3)),
      );

      final advisory = aiService.getSafeHandlingAdvisory(clothes);

      expect(advisory.title, contains('Clothing'));
      expect(advisory.recommendedContainer, contains('Waterproof'));
      expect(advisory.handlingTips.any((t) => t.contains('rain')), isTrue);
    });

    test('askCommunityAssistant provides correct answers for key platform concepts', () async {
      final otpAnswer = await aiService.askCommunityAssistant('How do I use the pickup OTP code?');
      expect(otpAnswer, contains('dual-OTP'));
      expect(otpAnswer, contains('Pickup Code'));
      expect(otpAnswer, contains('Receipt Code'));

      final breakdownAnswer = await aiService.askCommunityAssistant('What if my bike breaks down?');
      expect(breakdownAnswer, contains('Emergency'));
      expect(breakdownAnswer, contains('dispatch pool'));

      final fssaiAnswer = await aiService.askCommunityAssistant('What are the FSSAI food safety rules?');
      expect(fssaiAnswer, contains('FSSAI'));
      expect(fssaiAnswer, contains('never certifies food safety'));

      final limitAnswer = await aiService.askCommunityAssistant('What is the active task limit?');
      expect(limitAnswer, contains('2 active concurrent dispatch tasks'));
    });

    test('suggestCategory: suggests cooked food, requires Rule 14 disclaimer and allows manual correction', () {
      final suggestion = aiService.suggestCategory('Veg Dum Biryani with raita', filename: 'biryani_pot.jpg');
      expect(suggestion.categoryId, 'cooked_meals');
      expect(suggestion.type, DonationType.food);
      expect(suggestion.manualCorrectionAllowed, isTrue);
      expect(suggestion.foodSafetyDisclaimer, contains('Rule 14'));
      expect(suggestion.foodSafetyDisclaimer, contains('NOT certify food freshness'));
    });

    test('suggestCategory: rejects prohibited food freshness certification', () {
      expect(
        () => aiService.suggestCategory('certify food freshness before delivery'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('getDemandInsights: returns aggregated patterns with explicit uncertainty', () {
      final insights = aiService.getDemandInsights();
      expect(insights.peakSurplusWindow, contains('Dinner Banquet Surplus'));
      expect(insights.topDeficitZone, contains('Hadapsar'));
      expect(insights.uncertaintyNote, contains('±14.5% margin'));
      expect(insights.uncertaintyNote, contains('excludes informal offline distributions'));
    });
  });
}

