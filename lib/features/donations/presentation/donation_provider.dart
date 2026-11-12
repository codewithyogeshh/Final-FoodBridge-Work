import 'package:flutter/foundation.dart';
import '../domain/models/donation.dart';

class DonationProvider extends ChangeNotifier {
  final List<Donation> _donations = [];
  bool _isLoading = false;
  String? _errorMessage;
  DonationType? _selectedTypeFilter;
  String _searchQuery = '';

  DonationProvider() {
    _seedInitialData();
  }

  List<Donation> get allDonations => List.unmodifiable(_donations);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DonationType? get selectedTypeFilter => _selectedTypeFilter;
  String get searchQuery => _searchQuery;

  // Filtered donations for feeds
  List<Donation> get filteredDonations {
    return _donations.where((d) {
      if (_selectedTypeFilter != null && d.type != _selectedTypeFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = d.title.toLowerCase().contains(query);
        final matchesDesc = d.description.toLowerCase().contains(query);
        final matchesCity = d.city.toLowerCase().contains(query);
        final matchesAddress = d.pickupAddress.toLowerCase().contains(query);
        return matchesTitle || matchesDesc || matchesCity || matchesAddress;
      }
      return true;
    }).toList();
  }

  // Active listings for NGOs to claim
  List<Donation> get availableDonations =>
      filteredDonations.where((d) => d.status == DonationStatus.listed).toList();

  // NGO's claimed donations
  List<Donation> getDonationsClaimedByNgo(String ngoId) =>
      _donations.where((d) => d.claimedByNgoId == ngoId).toList();

  // Donor's own donations
  List<Donation> getDonationsByDonor(String donorId) =>
      _donations.where((d) => d.donorId == donorId).toList();

  // Volunteer available tasks (claimed by NGO, awaiting volunteer pickup)
  List<Donation> get volunteerAvailableTasks =>
      _donations.where((d) => d.status == DonationStatus.claimed).toList();

  // Volunteer's active tasks (assigned or in transit)
  List<Donation> getVolunteerActiveTasks(String volunteerId) => _donations
      .where((d) =>
          d.assignedVolunteerId == volunteerId &&
          (d.status == DonationStatus.assigned ||
              d.status == DonationStatus.pickedUp))
      .toList();

  // Volunteer's completed tasks
  List<Donation> getVolunteerCompletedTasks(String volunteerId) => _donations
      .where((d) =>
          d.assignedVolunteerId == volunteerId &&
          d.status == DonationStatus.delivered)
      .toList();

  // Impact metrics
  double get totalMealsRescued {
    return _donations
        .where((d) => d.isFood && d.status == DonationStatus.delivered)
        .fold(0.0, (acc, item) => acc + item.quantity);
  }

  int get totalClothingItemsRedistributed {
    return _donations
        .where((d) => d.isClothing && d.status == DonationStatus.delivered)
        .fold(0, (acc, item) => acc + item.quantity.toInt());
  }

  int get activeListingsCount =>
      _donations.where((d) => d.status == DonationStatus.listed).length;

  void setTypeFilter(DonationType? type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Donation? getDonationById(String id) {
    try {
      return _donations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new food or clothing donation
  Future<bool> createDonation(Donation donation) async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      _donations.insert(0, donation);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// NGO claims a donation
  Future<bool> claimDonation({
    required String donationId,
    required String ngoId,
    required String ngoName,
  }) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final current = _donations[index];
      _donations[index] = current.copyWith(
        status: DonationStatus.claimed,
        claimedByNgoId: ngoId,
        claimedByNgoName: ngoName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Volunteer accepts delivery task
  Future<bool> acceptVolunteerTask({
    required String donationId,
    required String volunteerId,
    required String volunteerName,
    String? phone,
  }) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final current = _donations[index];
      _donations[index] = current.copyWith(
        status: DonationStatus.assigned,
        assignedVolunteerId: volunteerId,
        assignedVolunteerName: volunteerName,
        assignedVolunteerPhone: phone,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Volunteer marks task as picked up from donor
  Future<bool> markPickedUp(String donationId) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    final current = _donations[index];
    _donations[index] = current.copyWith(
      status: DonationStatus.pickedUp,
      pickedUpAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  /// Volunteer marks task as delivered to NGO shelter
  Future<bool> markDelivered(String donationId) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    final current = _donations[index];
    _donations[index] = current.copyWith(
      status: DonationStatus.delivered,
      deliveredAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  /// Cancel a donation
  Future<bool> cancelDonation(String donationId) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    _donations[index] = _donations[index].copyWith(
      status: DonationStatus.cancelled,
    );
    notifyListeners();
    return true;
  }

  void _seedInitialData() {
    final now = DateTime.now();

    _donations.addAll([
      Donation(
        id: 'dn-101',
        donorId: 'usr-donor-101',
        donorName: 'The Green Leaf Bistro',
        donorPhone: '+91 98200 12345',
        title: '50 Veg Biryani Meal Boxes',
        description:
            'Freshly cooked vegetable dum biryani packed with raita. Kept under hot-holding warming station. Safe hygienic packaging.',
        quantity: 50,
        unit: 'meals',
        type: DonationType.food,
        status: DonationStatus.listed,
        pickupAddress: 'Shop 4, MG Road, Camp, Pune 411001',
        city: 'Pune',
        latitude: 18.5186,
        longitude: 73.8789,
        createdAt: now.subtract(const Duration(minutes: 45)),
        pickupDeadline: now.add(const Duration(hours: 3)),
        isVeg: true,
        prepTime: now.subtract(const Duration(hours: 1)),
        storageCondition: 'hot',
        allergenNotes: 'Contains dairy (curd/paneer), gluten-free, nut-free',
        safetyCharterAgreed: true,
      ),
      Donation(
        id: 'dn-102',
        donorId: 'usr-donor-102',
        donorName: 'Symbiosis Campus Cafeteria',
        donorPhone: '+91 98234 56789',
        title: '35 Poha & Upma Breakfast Packets',
        description:
            'Breakfast surplus prepared this morning. Packed in food-grade foil containers with disposable wooden spoons.',
        quantity: 35,
        unit: 'meals',
        type: DonationType.food,
        status: DonationStatus.listed,
        pickupAddress: 'Symbiosis Viman Nagar Campus, Pune 411014',
        city: 'Pune',
        latitude: 18.5679,
        longitude: 73.9143,
        createdAt: now.subtract(const Duration(hours: 1)),
        pickupDeadline: now.add(const Duration(hours: 4)),
        isVeg: true,
        prepTime: now.subtract(const Duration(hours: 2)),
        storageCondition: 'ambient',
        allergenNotes: 'Contains peanuts in poha',
        safetyCharterAgreed: true,
      ),
      Donation(
        id: 'dn-103',
        donorId: 'usr-donor-103',
        donorName: 'Rahul & Meera Sharma',
        donorPhone: '+91 94220 88776',
        title: '25 Winter Jackets & Woolen Blankets',
        description:
            'Cleaned and sanitized winter warm wear for adults and kids. Excellent condition ready for immediate night shelter distribution.',
        quantity: 25,
        unit: 'pieces',
        type: DonationType.clothing,
        status: DonationStatus.listed,
        pickupAddress: 'Flat 402, Nyati Enclave, Mohammadwadi, Pune 411060',
        city: 'Pune',
        latitude: 18.4820,
        longitude: 73.9160,
        createdAt: now.subtract(const Duration(hours: 3)),
        pickupDeadline: now.add(const Duration(days: 2)),
        clothingCategory: 'winter',
        conditionGrade: 'like_new',
        isWashedAndClean: true,
      ),
      Donation(
        id: 'dn-104',
        donorId: 'usr-donor-101',
        donorName: 'The Green Leaf Bistro',
        donorPhone: '+91 98200 12345',
        title: '40 Chapati & Paneer Bhurji Combos',
        description:
            'Prepared for corporate lunch event surplus. Kept warm in food warmers.',
        quantity: 40,
        unit: 'meals',
        type: DonationType.food,
        status: DonationStatus.claimed,
        pickupAddress: 'Shop 4, MG Road, Camp, Pune 411001',
        city: 'Pune',
        latitude: 18.5186,
        longitude: 73.8789,
        createdAt: now.subtract(const Duration(hours: 2)),
        pickupDeadline: now.add(const Duration(hours: 2, minutes: 30)),
        claimedByNgoId: 'usr-ngo-202',
        claimedByNgoName: 'Asha Children Foundation',
        isVeg: true,
        storageCondition: 'hot',
        safetyCharterAgreed: true,
      ),
      Donation(
        id: 'dn-105',
        donorId: 'usr-donor-104',
        donorName: 'Grand Hyatt Convention',
        donorPhone: '+91 98811 00223',
        title: '60 Assorted Fruit & Snack Hampers',
        description:
            'Fresh apples, bananas, biscuits and juice cartons from evening seminar.',
        quantity: 60,
        unit: 'boxes',
        type: DonationType.food,
        status: DonationStatus.assigned,
        pickupAddress: 'Kalyani Nagar, Pune 411006',
        city: 'Pune',
        latitude: 18.5463,
        longitude: 73.9033,
        createdAt: now.subtract(const Duration(hours: 3)),
        pickupDeadline: now.add(const Duration(hours: 5)),
        claimedByNgoId: 'usr-ngo-202',
        claimedByNgoName: 'Asha Children Foundation',
        assignedVolunteerId: 'usr-vol-303',
        assignedVolunteerName: 'Rohit Kulkarni',
        assignedVolunteerPhone: '+91 97654 99887',
        isVeg: true,
        storageCondition: 'ambient',
        safetyCharterAgreed: true,
      ),
      Donation(
        id: 'dn-106',
        donorId: 'usr-donor-105',
        donorName: 'Rotary Club Pune Central',
        donorPhone: '+91 99221 44332',
        title: '50 School Uniforms & Shoes (Ages 6-12)',
        description:
            'Brand new navy blue uniforms and black school shoes donated during annual drive.',
        quantity: 50,
        unit: 'sets',
        type: DonationType.clothing,
        status: DonationStatus.delivered,
        pickupAddress: 'Deccan Gymkhana, Pune 411004',
        city: 'Pune',
        latitude: 18.5167,
        longitude: 73.8417,
        createdAt: now.subtract(const Duration(days: 2)),
        pickupDeadline: now.subtract(const Duration(days: 1)),
        claimedByNgoId: 'usr-ngo-202',
        claimedByNgoName: 'Asha Children Foundation',
        assignedVolunteerId: 'usr-vol-303',
        assignedVolunteerName: 'Rohit Kulkarni',
        pickedUpAt: now.subtract(const Duration(days: 1, hours: 4)),
        deliveredAt: now.subtract(const Duration(days: 1, hours: 2)),
        clothingCategory: 'kids',
        conditionGrade: 'brand_new',
        isWashedAndClean: true,
      ),
    ]);
  }
}
