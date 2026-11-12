import '../../features/donations/domain/models/donation.dart';

class SmartMatchResult {
  final int matchScorePercent;
  final String matchTier; // 'Best Match (95%)', 'Great Match (88%)', etc.
  final String reason;
  final bool isHighPriority;

  const SmartMatchResult({
    required this.matchScorePercent,
    required this.matchTier,
    required this.reason,
    required this.isHighPriority,
  });
}

class SafeHandlingAdvisory {
  final String title;
  final List<String> handlingTips;
  final String recommendedContainer;
  final String maxTransitWindow;
  final String disclaimer;

  const SafeHandlingAdvisory({
    required this.title,
    required this.handlingTips,
    required this.recommendedContainer,
    required this.maxTransitWindow,
    this.disclaimer =
        'Notice: This AI advisory provides logistics & packaging guidelines only. It does not certify food safety or hygiene (FSSAI compliance remains donor responsibility).',
  });
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Calculate match compatibility between donation and NGO/volunteer route
  SmartMatchResult calculateMatch({
    required Donation donation,
    double distanceKm = 3.5,
  }) {
    int score = 80;
    final List<String> reasons = [];
    bool highPriority = false;

    // 1. Distance proximity
    if (distanceKm <= 3.0) {
      score += 15;
      reasons.add('Ultra-close proximity (~${distanceKm.toStringAsFixed(1)} km)');
    } else if (distanceKm <= 7.0) {
      score += 8;
      reasons.add('Within standard delivery radius (${distanceKm.toStringAsFixed(1)} km)');
    } else {
      score -= 10;
      reasons.add('Extended transit distance (${distanceKm.toStringAsFixed(1)} km)');
    }

    // 2. Food urgency & shelf life
    if (donation.isFood) {
      final hoursLeft = donation.timeRemaining.inHours;
      if (hoursLeft <= 3 && !donation.timeRemaining.isNegative) {
        score += 10;
        highPriority = true;
        reasons.add('Expiring soon (urgent rescue window < 3 hrs)');
      } else {
        reasons.add('Stable pickup window');
      }

      if (donation.isVeg) {
        score += 5;
        reasons.add('Pure-veg widely accepted across all shelters');
      }
    } else {
      score += 5;
      reasons.add('Non-perishable clothing redistribution');
    }

    final finalScore = score.clamp(50, 99);
    final String tier;
    if (finalScore >= 90) {
      tier = 'High Match ($finalScore%)';
    } else if (finalScore >= 80) {
      tier = 'Good Match ($finalScore%)';
    } else {
      tier = 'Standard Match ($finalScore%)';
    }

    return SmartMatchResult(
      matchScorePercent: finalScore,
      matchTier: tier,
      reason: reasons.join(' • '),
      isHighPriority: highPriority,
    );
  }

  /// AI-assisted safe transport advisory for riders and volunteers
  SafeHandlingAdvisory getSafeHandlingAdvisory(Donation donation) {
    if (donation.isClothing) {
      return const SafeHandlingAdvisory(
        title: 'Clothing Logistics Advisory',
        handlingTips: [
          'Keep packages covered in waterproof rain-sheet or delivery bag during transit.',
          'Verify that bundles remain neatly folded and dry upon shelter arrival.',
          'Confirm handover count directly with shelter inventory manager.',
        ],
        recommendedContainer: 'Waterproof Delivery Bag / Cargo Box',
        maxTransitWindow: 'Flexible (within scheduled 48h deadline)',
      );
    }

    // Food advisory based on storage condition
    final condition = donation.storageCondition?.toLowerCase().trim() ?? 'ambient';

    if (condition == 'hot') {
      return SafeHandlingAdvisory(
        title: 'Hot Food Logistics Advisory',
        handlingTips: [
          'Keep insulated thermal delivery box tightly sealed to maintain holding temperature (>60°C).',
          'Avoid sudden tilt to prevent curry/gravy spillage across foil containers.',
          'Prioritize direct non-stop transit to avoid temperature drop.',
          if (donation.allergenNotes != null)
            'Disclosed Allergens: ${donation.allergenNotes} - Ensure container seal remains uncompromised.',
        ],
        recommendedContainer: 'Thermal Insulated Hot-Bag / Delivery Crate',
        maxTransitWindow: 'Deliver within 45–60 minutes',
      );
    } else if (condition == 'chilled') {
      return SafeHandlingAdvisory(
        title: 'Cold Storage / Dairy Advisory',
        handlingTips: [
          'Transport in cooler box with active ice-gel packs (<8°C).',
          'Do not place in direct contact with hot vehicle engine compartments.',
          'Inspect sealed lids upon pickup.',
        ],
        recommendedContainer: 'Ice-Gel Cooler Box / Insulated Carrier',
        maxTransitWindow: 'Deliver within 60–90 minutes',
      );
    } else {
      return SafeHandlingAdvisory(
        title: 'Dry Goods & Produce Advisory',
        handlingTips: [
          'Keep containers elevated from vehicle floor and protected from dust/exhaust.',
          'Handle bakery boxes gently to prevent crushing.',
          'Verify packaging seal before departure from donor premises.',
        ],
        recommendedContainer: 'Standard Clean Delivery Crate',
        maxTransitWindow: 'Deliver within 2 hours',
      );
    }
  }

  /// Automated FAQ assistant responses
  Future<String> askCommunityAssistant(String query) async {
    final q = query.toLowerCase();

    if (q.contains('otp') || q.contains('code') || q.contains('verification')) {
      return 'FoodBridge uses a secure dual-OTP system: 1) Ask the donor for their 4-digit Pickup Code when you collect the cargo. 2) Ask the NGO shelter manager for their 4-digit Receipt Code when you deliver. Both codes verify physical custody handover.';
    }

    if (q.contains('cancel') ||
        q.contains('breakdown') ||
        q.contains('break down') ||
        q.contains('bike') ||
        q.contains('vehicle') ||
        q.contains('flat tire') ||
        q.contains('emergency')) {
      return 'If you face a vehicle breakdown, flat tire, or emergency, tap the red Emergency icon in the Live Mission screen to release the task. The system will immediately place it back in the dispatch pool for another nearby volunteer.';
    }

    if (q.contains('fssai') || q.contains('food safety') || q.contains('hygiene')) {
      return 'Under FSSAI Surplus Food Regulations and FoodBridge Charter, all donors must certify that food was prepared under hygienic conditions, packed hygienically, and stored at appropriate temperatures. AI assists with logistics but never certifies food safety.';
    }

    if (q.contains('limit') || q.contains('active task') || q.contains('2 task')) {
      return 'To ensure fast and reliable rescues, volunteers can have at most 2 active concurrent dispatch tasks at any time. Once you complete delivery of one mission, you can accept new tasks.';
    }

    return 'FoodBridge connects food & clothing donors, verified NGOs, and volunteer couriers to reduce wastage. For further assistance, contact community dispatch support at support@foodbridge.org.';
  }
}
