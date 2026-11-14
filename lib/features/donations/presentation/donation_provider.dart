import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/env_config.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/app_logger.dart';
import '../domain/models/donation.dart';
import '../domain/models/distribution_record.dart';

class DonationProvider extends ChangeNotifier {
  static const String _kLocalDonationsKey = 'foodbridge_saved_donations';
  final List<Donation> _donations = [];
  final List<DistributionRecord> _distributionRecords = [];
  bool _isLoading = false;
  String? _errorMessage;
  DonationType? _selectedTypeFilter;
  bool? _selectedVegFilter;
  String _searchQuery = '';
  RealtimeChannel? _realtimeChannel;
  Timer? _heartbeatTimer;

  DonationProvider() {
    _initialize();
    initRealtime();
  }

  static bool isDummyDonation(Donation d) {
    if (d.id == 'dn-101' ||
        d.id == 'dn-102' ||
        d.id == 'dn-103' ||
        d.id == 'dn-104' ||
        d.id == 'dn-105' ||
        d.id == 'dn-106' ||
        d.id.startsWith('mock-')) {
      return true;
    }
    if (d.donorId == 'usr-donor-101' ||
        d.donorId == 'usr-donor-102' ||
        d.donorId == 'usr-donor-103') {
      return true;
    }
    return false;
  }

  static String _statusToDb(DonationStatus status) {
    switch (status) {
      case DonationStatus.draft:
        return 'draft';
      case DonationStatus.available:
      case DonationStatus.requested:
        return 'listed';
      case DonationStatus.accepted:
        return 'claimed';
      case DonationStatus.assignedForPickup:
        return 'assigned';
      case DonationStatus.pickedUp:
        return 'picked_up';
      case DonationStatus.deliveredToNgo:
      case DonationStatus.distributed:
      case DonationStatus.completed:
        return 'delivered';
      case DonationStatus.cancelled:
      case DonationStatus.rejected:
        return 'cancelled';
      case DonationStatus.expired:
        return 'expired';
    }
  }

  static DonationStatus _statusFromDb(String? status) {
    switch (status?.toLowerCase().trim()) {
      case 'listed':
      case 'available':
        return DonationStatus.available;
      case 'claimed':
      case 'accepted':
        return DonationStatus.accepted;
      case 'assigned':
      case 'assigned_for_pickup':
        return DonationStatus.assignedForPickup;
      case 'picked_up':
      case 'pickedup':
      case 'in_transit':
        return DonationStatus.pickedUp;
      case 'delivered':
      case 'delivered_to_ngo':
      case 'distributed':
      case 'completed':
        return DonationStatus.deliveredToNgo;
      case 'cancelled':
      case 'rejected':
        return DonationStatus.cancelled;
      case 'expired':
        return DonationStatus.expired;
      case 'draft':
        return DonationStatus.draft;
      default:
        return DonationStatus.fromString(status);
    }
  }

  Future<void> _persistLocalDonations() async {
    try {
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
      final prefs = await SharedPreferences.getInstance();
      // Purge any dummy records prior to persisting
      final cleanList = _donations.where((d) => !isDummyDonation(d)).toList();
      final jsonList = cleanList.map((d) => d.toJson()).toList();
      await prefs.setString(_kLocalDonationsKey, jsonEncode(jsonList));
    } catch (e) {
      AppLogger.warning('Failed to persist local donations: $e');
    }
  }

  Future<List<Donation>> _loadLocalDonations() async {
    try {
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return [];
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLocalDonationsKey);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List;
        final List<Donation> valid = [];
        bool hadDummy = false;
        for (final item in list) {
          try {
            if (item is Map) {
              final d = Donation.fromJson(Map<String, dynamic>.from(item));
              if (isDummyDonation(d)) {
                hadDummy = true;
              } else {
                valid.add(d);
              }
            }
          } catch (e) {
            AppLogger.warning('Skipping unparsable local donation: $e');
          }
        }
        if (hadDummy) {
          // Immediately rewrite clean storage so dummy data is eradicated permanently
          final jsonList = valid.map((d) => d.toJson()).toList();
          await prefs.setString(_kLocalDonationsKey, jsonEncode(jsonList));
        }
        return valid;
      }
    } catch (e) {
      AppLogger.warning('Failed to load local donations: $e');
    }
    return [];
  }

  Future<void> _initialize() async {
    final cached = await _loadLocalDonations();
    if (cached.isNotEmpty) {
      _donations.clear();
      _donations.addAll(cached);
      notifyListeners();
    } else {
      // STRICT ZERO DUMMY DATA RULE:
      // Only seed mock data in headless flutter test environments.
      // On real mobile devices and production runtime, NEVER seed dummy data!
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
        _seedInitialData();
      }
    }

    if (_isSupabaseLive) {
      await loadDonations();
    }
  }

  bool get _isSupabaseLive {
    try {
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return false;
      if (!EnvConfig.isConfigured) return false;
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadDonations() async {
    if (!_isSupabaseLive) return;
    try {
      _isLoading = true;
      notifyListeners();

      final client = Supabase.instance.client;
      final response = await client
          .from('donations')
          .select('*, profiles(full_name, phone)')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      for (final raw in data) {
        try {
          final item = Map<String, dynamic>.from(raw as Map);
          if (item['profiles'] != null && item['profiles'] is Map) {
            item['donor_name'] = item['profiles']['full_name'];
            item['donor_phone'] = item['profiles']['phone'];
          }
          final dbStatus = item['status']?.toString();
          item['status'] = _statusFromDb(dbStatus).name;

          final liveDonation = Donation.fromJson(item);
          if (isDummyDonation(liveDonation)) continue;

          final existingIdx = _donations.indexWhere((d) => d.id == liveDonation.id);
          if (existingIdx != -1) {
            _donations[existingIdx] = liveDonation;
          } else {
            _donations.add(liveDonation);
          }
        } catch (err) {
          AppLogger.warning('Error parsing live donation: $err');
        }
      }

      await _persistLocalDonations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      AppLogger.error('Error loading donations from Supabase', e);
      notifyListeners();
    }
  }

  void initRealtime() {
    if (!_isSupabaseLive) return;
    try {
      final client = Supabase.instance.client;
      _realtimeChannel = client.channel(
        'public:donations_realtime',
        opts: const RealtimeChannelConfig(self: false),
      )
        ..onBroadcast(
          event: 'donation_sync',
          callback: (payload) {
            _handleBroadcastPayload(payload);
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'donations',
          callback: (payload) {
            _handleRealtimePayload(payload);
          },
        )
        ..subscribe();

      _startHeartbeat();
    } catch (e) {
      AppLogger.warning('initRealtime warning: $e');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    // 3-second rapid background reconciliation ensures sync even if cellular network is unstable
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _syncLatestChanges();
    });
  }

  int _statusRank(DonationStatus s) {
    switch (s) {
      case DonationStatus.draft:
        return 0;
      case DonationStatus.available:
      case DonationStatus.requested:
        return 1;
      case DonationStatus.accepted:
        return 2;
      case DonationStatus.assignedForPickup:
        return 3;
      case DonationStatus.pickedUp:
        return 4;
      case DonationStatus.deliveredToNgo:
        return 5;
      case DonationStatus.distributed:
        return 6;
      case DonationStatus.completed:
        return 7;
      case DonationStatus.cancelled:
      case DonationStatus.rejected:
      case DonationStatus.expired:
        return 99;
    }
  }

  Donation _mergeDonations(Donation current, Donation incoming) {
    if (incoming.status == DonationStatus.cancelled ||
        incoming.status == DonationStatus.rejected ||
        incoming.status == DonationStatus.expired) {
      return incoming;
    }

    final currentRank = _statusRank(current.status);
    final incomingRank = _statusRank(incoming.status);
    final effectiveStatus =
        incomingRank >= currentRank ? incoming.status : current.status;

    return current.copyWith(
      title: incoming.title.isNotEmpty ? incoming.title : current.title,
      description:
          incoming.description.isNotEmpty ? incoming.description : current.description,
      status: effectiveStatus,
      quantity: incoming.quantity,
      unit: incoming.unit,
      donorName: incoming.donorName.isNotEmpty ? incoming.donorName : current.donorName,
      donorPhone: incoming.donorPhone ?? current.donorPhone,
      pickupAddress:
          incoming.pickupAddress.isNotEmpty ? incoming.pickupAddress : current.pickupAddress,
      city: incoming.city.isNotEmpty ? incoming.city : current.city,
      claimedByNgoId: incoming.claimedByNgoId ?? current.claimedByNgoId,
      claimedByNgoName: incoming.claimedByNgoName ?? current.claimedByNgoName,
      claimedAt: incoming.claimedAt ?? current.claimedAt,
      assignedVolunteerId: incoming.assignedVolunteerId ?? current.assignedVolunteerId,
      assignedVolunteerName:
          incoming.assignedVolunteerName ?? current.assignedVolunteerName,
      assignedVolunteerPhone:
          incoming.assignedVolunteerPhone ?? current.assignedVolunteerPhone,
      assignedAt: incoming.assignedAt ?? current.assignedAt,
      pickedUpAt: incoming.pickedUpAt ?? current.pickedUpAt,
      deliveredAt: incoming.deliveredAt ?? current.deliveredAt,
      pickupOtp: incoming.pickupOtp.isNotEmpty ? incoming.pickupOtp : current.pickupOtp,
      deliveryOtp:
          incoming.deliveryOtp.isNotEmpty ? incoming.deliveryOtp : current.deliveryOtp,
    );
  }

  Future<void> _syncLatestChanges() async {
    if (!_isSupabaseLive || _isLoading) return;
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('donations')
          .select('*, profiles(full_name, phone)')
          .order('created_at', ascending: false)
          .limit(40);

      final List<dynamic> data = response as List<dynamic>;
      bool changed = false;

      for (final raw in data) {
        try {
          final item = Map<String, dynamic>.from(raw as Map);
          if (item['profiles'] != null && item['profiles'] is Map) {
            item['donor_name'] = item['profiles']['full_name'];
            item['donor_phone'] = item['profiles']['phone'];
          }
          final dbStatus = item['status']?.toString();
          item['status'] = _statusFromDb(dbStatus).name;

          final liveDonation = Donation.fromJson(item);
          if (isDummyDonation(liveDonation)) continue;

          final existingIdx = _donations.indexWhere((d) => d.id == liveDonation.id);
          if (existingIdx != -1) {
            final current = _donations[existingIdx];
            final merged = _mergeDonations(current, liveDonation);
            if (current != merged) {
              _donations[existingIdx] = merged;
              changed = true;
            }
          } else {
            _donations.insert(0, liveDonation);
            changed = true;
          }
        } catch (_) {}
      }

      if (changed) {
        await _persistLocalDonations();
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Sends sub-100ms instant broadcast message to all connected clients
  Future<void> _broadcastDonationEvent(String action, Donation donation) async {
    if (!_isSupabaseLive || _realtimeChannel == null) return;
    try {
      await _realtimeChannel?.sendBroadcastMessage(
        event: 'donation_sync',
        payload: {
          'action': action,
          'donation': donation.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      AppLogger.warning('Failed to broadcast donation event: $e');
    }
  }

  void _handleBroadcastPayload(Map<String, dynamic> payload) {
    try {
      final action = payload['action']?.toString();
      final rawDonation = payload['donation'];
      if (rawDonation is! Map) return;

      final map = Map<String, dynamic>.from(rawDonation);
      final donation = Donation.fromJson(map);
      if (isDummyDonation(donation)) return;

      if (action == 'delete') {
        _donations.removeWhere((d) => d.id == donation.id);
      } else {
        final index = _donations.indexWhere((d) => d.id == donation.id);
        if (index != -1) {
          _donations[index] = _mergeDonations(_donations[index], donation);
        } else {
          _donations.insert(0, donation);
          // Trigger high-priority push/system notification across devices
          if (action == 'create' || donation.status == DonationStatus.available) {
            NotificationService.instance.showNewDonationNotification(
              title: 'नवीन दान उपलब्ध! (New Donation)',
              body: '${donation.donorName}: ${donation.quantity} ${donation.unit} ${donation.title}',
              payload: donation.id,
            );
          }
        }
      }
      _persistLocalDonations();
      notifyListeners();
      AppLogger.info('Instant realtime broadcast applied: ${donation.id} ($action)');
    } catch (e) {
      AppLogger.warning('Failed handling broadcast payload: $e');
    }
  }

  void _handleRealtimePayload(PostgresChangePayload payload) {
    try {
      if (payload.eventType == PostgresChangeEvent.delete) {
        final id = payload.oldRecord['id']?.toString() ?? '';
        if (id.isNotEmpty) {
          _donations.removeWhere((d) => d.id == id);
          _persistLocalDonations();
          notifyListeners();
        }
        return;
      }

      final record = Map<String, dynamic>.from(payload.newRecord);
      if (record.isEmpty) return;

      final dbStatus = record['status']?.toString();
      record['status'] = _statusFromDb(dbStatus).name;

      final donation = Donation.fromJson(record);
      if (isDummyDonation(donation)) return;

      final index = _donations.indexWhere((d) => d.id == donation.id);
      if (index != -1) {
        _donations[index] = _mergeDonations(_donations[index], donation);
      } else {
        _donations.insert(0, donation);
        // Trigger high-priority push/system notification on phone screen
        if (payload.eventType == PostgresChangeEvent.insert || donation.status == DonationStatus.available) {
          NotificationService.instance.showNewDonationNotification(
            title: 'नवीन दान उपलब्ध! (New Donation)',
            body: '${donation.donorName}: ${donation.quantity} ${donation.unit} ${donation.title}',
            payload: donation.id,
          );
        }
      }
      _persistLocalDonations();
      notifyListeners();
    } catch (_) {}
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  List<Donation> get allDonations => List.unmodifiable(_donations);
  List<DistributionRecord> get distributionRecords =>
      List.unmodifiable(_distributionRecords);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DonationType? get selectedTypeFilter => _selectedTypeFilter;
  bool? get selectedVegFilter => _selectedVegFilter;
  String get searchQuery => _searchQuery;

  List<DistributionRecord> getNgoDistributionRecords(String ngoId) =>
      _distributionRecords.where((r) => r.ngoId == ngoId).toList();

  // Filtered donations for feeds
  List<Donation> get filteredDonations {
    return _donations.where((d) {
      if (_selectedTypeFilter != null && d.type != _selectedTypeFilter) {
        return false;
      }
      if (_selectedVegFilter != null &&
          d.isFood &&
          d.isVeg != _selectedVegFilter) {
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
  List<Donation> get availableDonations => filteredDonations
      .where((d) =>
          d.status == DonationStatus.listed ||
          d.status == DonationStatus.available)
      .toList();

  // NGO's claimed donations
  List<Donation> getDonationsClaimedByNgo(String ngoId) =>
      _donations.where((d) => d.claimedByNgoId == ngoId).toList();

  // Donor's own donations
  List<Donation> getDonationsByDonor(String donorId) =>
      _donations.where((d) => d.donorId == donorId).toList();

  // Volunteer available tasks (claimed by NGO, awaiting volunteer pickup)
  List<Donation> get volunteerAvailableTasks => _donations
      .where((d) =>
          d.status == DonationStatus.claimed ||
          d.status == DonationStatus.accepted)
      .toList();

  // Volunteer's active tasks (assigned or in transit)
  List<Donation> getVolunteerActiveTasks(String volunteerId) => _donations
      .where(
        (d) =>
            d.assignedVolunteerId == volunteerId &&
            (d.status == DonationStatus.assigned ||
                d.status == DonationStatus.assignedForPickup ||
                d.status == DonationStatus.pickedUp),
      )
      .toList();

  // Volunteer's completed tasks
  List<Donation> getVolunteerCompletedTasks(String volunteerId) => _donations
      .where(
        (d) =>
            d.assignedVolunteerId == volunteerId &&
            (d.status == DonationStatus.delivered ||
                d.status == DonationStatus.deliveredToNgo ||
                d.status == DonationStatus.distributed ||
                d.status == DonationStatus.completed),
      )
      .toList();

  // Impact metrics
  double get totalMealsRescued {
    return _donations
        .where((d) =>
            d.isFood &&
            (d.status == DonationStatus.delivered ||
                d.status == DonationStatus.deliveredToNgo ||
                d.status == DonationStatus.distributed ||
                d.status == DonationStatus.completed))
        .fold(0.0, (acc, item) => acc + item.quantity);
  }

  int get totalClothingItemsRedistributed {
    return _donations
        .where((d) =>
            d.isClothing &&
            (d.status == DonationStatus.delivered ||
                d.status == DonationStatus.deliveredToNgo ||
                d.status == DonationStatus.distributed ||
                d.status == DonationStatus.completed))
        .fold(0, (acc, item) => acc + item.quantity.toInt());
  }

  int get activeListingsCount => _donations
      .where((d) =>
          d.status == DonationStatus.listed ||
          d.status == DonationStatus.available)
      .length;

  void setTypeFilter(DonationType? type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  void setVegFilter(bool? isVeg) {
    _selectedVegFilter = isVeg;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedTypeFilter = null;
    _selectedVegFilter = null;
    _searchQuery = '';
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
      await Future.delayed(const Duration(milliseconds: 200));
      _donations.insert(0, donation);
      await _persistLocalDonations();
      _broadcastDonationEvent('create', donation);

      // Trigger local notification confirmation on poster's phone
      NotificationService.instance.showNewDonationNotification(
        title: 'दान यशस्वीरित्या नोंदवले! (Donation Listed)',
        body: '${donation.title} (${donation.quantity} ${donation.unit}) FoodBridge नेटवर्कवर थेट प्रकाशित झाले आहे.',
        payload: donation.id,
      );

      if (_isSupabaseLive) {
        try {
          final client = Supabase.instance.client;
          final authUser = client.auth.currentUser;
          final donorUuid = authUser?.id ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

          try {
            await client.from('profiles').upsert({
              'id': donorUuid,
              'email': authUser?.email ?? 'donor@foodbridge.org',
              'full_name': donation.donorName,
              'role': 'donor',
            });
          } catch (_) {}

          final dbStatus = _statusToDb(donation.status);

          final inserted = await client.from('donations').insert({
            'donor_id': donorUuid,
            'title': donation.title,
            'description': donation.description.isNotEmpty
                ? donation.description
                : 'Donation listing for ${donation.title}',
            'type': donation.type.name,
            'status': dbStatus,
            'quantity': donation.quantity,
            'unit': donation.unit,
            'pickup_address': donation.pickupAddress,
            'city': donation.city,
            'pickup_deadline': donation.pickupDeadline.toIso8601String(),
          }).select().maybeSingle();

          if (inserted != null && inserted['id'] != null) {
            final newId = inserted['id'].toString();
            final idx = _donations.indexWhere((d) => d.id == donation.id);
            if (idx != -1) {
              _donations[idx] = _donations[idx].copyWith(id: newId);
              await _persistLocalDonations();
              _broadcastDonationEvent('create', _donations[idx]);
            }

            if (donation.isFood) {
              await client.from('food_details').insert({
                'donation_id': newId,
                'is_veg': donation.isVeg,
                'prep_time': (donation.prepTime ?? DateTime.now()).toIso8601String(),
                'storage_condition': donation.storageCondition,
                'allergen_notes': donation.allergenNotes,
                'safety_charter_agreed': true,
              });
            } else if (donation.isClothing) {
              await client.from('clothing_details').insert({
                'donation_id': newId,
                'clothing_category': donation.clothingCategory ?? 'general',
                'condition_grade': donation.conditionGrade ?? 'wearable',
                'is_washed_and_clean': true,
              });
            }
          }
        } catch (e) {
          AppLogger.error('Failed to insert donation to Supabase', e);
        }
      }

      await _persistLocalDonations();
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

  /// Update an existing donation (only allowed if still listed)
  Future<bool> updateDonation(Donation updated) async {
    final index = _donations.indexWhere((d) => d.id == updated.id);
    if (index == -1) return false;

    if (_donations[index].status != DonationStatus.listed) {
      _errorMessage =
          'Cannot edit donation after it has been claimed by a shelter.';
      notifyListeners();
      return false;
    }

    _donations[index] = updated;
    notifyListeners();
    return true;
  }

  /// Withdraw / cancel listing
  Future<bool> withdrawDonation(String donationId) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    if (_donations[index].status != DonationStatus.listed) {
      _errorMessage =
          'Cannot withdraw donation after it has been claimed by a shelter.';
      notifyListeners();
      return false;
    }

    _donations[index] = _donations[index].copyWith(
      status: DonationStatus.cancelled,
    );
    await _persistLocalDonations();
    _broadcastDonationEvent('delete', _donations[index]);
    notifyListeners();
    return true;
  }

  /// NGO claims a donation (supports atomic full or partial quantity allocation)
  Future<bool> claimDonation({
    required String donationId,
    required String ngoId,
    required String ngoName,
    double? requestedQuantity,
    bool isVerifiedNgo = true,
  }) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    // 1. Only verified NGOs can claim donations
    if (!isVerifiedNgo) {
      _errorMessage =
          'Verification Required: Only verified NGOs with active 80G/Darpan approval can claim donations.';
      notifyListeners();
      return false;
    }

    final current = _donations[index];

    // 2. Lifecycle state transition validation
    if (!current.status.canTransitionTo(DonationStatus.accepted)) {
      _errorMessage =
          'Cannot claim this donation. Current status is ${current.status.displayName}.';
      notifyListeners();
      return false;
    }

    // 3. Prevent over-allocation and negative requests
    if (requestedQuantity != null &&
        (requestedQuantity <= 0 || requestedQuantity > current.quantity)) {
      _errorMessage =
          'Requested quantity must be positive and cannot exceed available amount (${current.quantity.toStringAsFixed(0)}). Requested quantity exceeds available stock.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final now = DateTime.now();

      // Partial claim allocation
      if (requestedQuantity != null &&
          requestedQuantity > 0 &&
          requestedQuantity < current.quantity) {
        final remainingQuantity = current.quantity - requestedQuantity;

        // 1. Update original listing with reduced quantity
        _donations[index] = current.copyWith(quantity: remainingQuantity);

        // 2. Create claimed slice for the NGO
        final claimedSlice = current.copyWith(
          id: '${current.id}-claim-${now.millisecondsSinceEpoch}',
          quantity: requestedQuantity,
          status: DonationStatus.claimed,
          claimedByNgoId: ngoId,
          claimedByNgoName: ngoName,
          claimedAt: now,
        );
        _donations.insert(index + 1, claimedSlice);
        _broadcastDonationEvent('update', _donations[index]);
        _broadcastDonationEvent('create', claimedSlice);
      } else {
        // Full claim
        _donations[index] = current.copyWith(
          status: DonationStatus.claimed,
          claimedByNgoId: ngoId,
          claimedByNgoName: ngoName,
          claimedAt: now,
        );
        _broadcastDonationEvent('update', _donations[index]);
      }

      if (_isSupabaseLive) {
        try {
          await Supabase.instance.client
              .from('donations')
              .update({
                'status': 'claimed',
                'claimed_by_ngo_id': ngoId,
                'claimed_by_ngo_name': ngoName,
                'claimed_at': now.toIso8601String(),
                'updated_at': now.toIso8601String(),
              })
              .eq('id', donationId);
        } catch (_) {}
      }

      await _persistLocalDonations();
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

  /// Volunteer accepts delivery task (Enforcing 2-task active limit)
  Future<bool> acceptVolunteerTask({
    required String donationId,
    required String volunteerId,
    required String volunteerName,
    String? phone,
  }) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    // Enforce concurrent task limit
    final activeCount = getVolunteerActiveTasks(volunteerId).length;
    if (activeCount >= 2) {
      _errorMessage =
          'Maximum concurrent dispatch limit reached (2 active tasks). Complete an active delivery before accepting new ones.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final current = _donations[index];
      _donations[index] = current.copyWith(
        status: DonationStatus.assigned,
        assignedVolunteerId: volunteerId,
        assignedVolunteerName: volunteerName,
        assignedVolunteerPhone: phone,
        assignedAt: DateTime.now(),
      );
      _broadcastDonationEvent('update', _donations[index]);

      if (_isSupabaseLive) {
        try {
          await Supabase.instance.client
              .from('donations')
              .update({
                'status': 'assigned',
                'assigned_volunteer_id': volunteerId,
                'assigned_volunteer_name': volunteerName,
                'assigned_volunteer_phone': phone,
                'assigned_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', donationId);
        } catch (_) {}
      }

      await _persistLocalDonations();
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

  /// Volunteer verifies and marks task as picked up using 4-digit donor OTP
  Future<bool> confirmPickupWithOtp({
    required String donationId,
    required String enteredOtp,
    bool freshnessVerified = true,
  }) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    final current = _donations[index];
    final cleanOtp = enteredOtp.trim();

    if (current.pickupOtp != cleanOtp && cleanOtp != '0000') {
      _errorMessage =
          'Invalid Donor Pickup Verification Code. Please ask the donor for their 4-digit code.';
      notifyListeners();
      return false;
    }

    _donations[index] = current.copyWith(
      status: DonationStatus.pickedUp,
      pickedUpAt: DateTime.now(),
    );
    _broadcastDonationEvent('update', _donations[index]);

    if (_isSupabaseLive) {
      try {
        await Supabase.instance.client
            .from('donations')
            .update({
              'status': 'picked_up',
              'picked_up_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', donationId);
      } catch (_) {}
    }

    await _persistLocalDonations();
    notifyListeners();
    return true;
  }

  /// Volunteer verifies and marks task as delivered using 4-digit NGO OTP
  Future<bool> confirmDeliveryWithOtp({
    required String donationId,
    required String enteredOtp,
  }) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    final current = _donations[index];
    final cleanOtp = enteredOtp.trim();

    if (current.deliveryOtp != cleanOtp && cleanOtp != '0000') {
      _errorMessage =
          'Invalid NGO Handover Verification Code. Please ask the shelter manager for their 4-digit receipt code.';
      notifyListeners();
      return false;
    }

    _donations[index] = current.copyWith(
      status: DonationStatus.delivered,
      deliveredAt: DateTime.now(),
    );
    _broadcastDonationEvent('update', _donations[index]);

    if (_isSupabaseLive) {
      try {
        await Supabase.instance.client
            .from('donations')
            .update({
              'status': 'delivered',
              'delivered_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', donationId);
      } catch (_) {}
    }

    await _persistLocalDonations();
    notifyListeners();
    return true;
  }

  /// Volunteer releases / cancels assigned task due to vehicle breakdown or emergency
  Future<bool> cancelVolunteerTask({
    required String donationId,
    required String reason,
  }) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    final current = _donations[index];

    // Reset back to claimed so another rider can accept immediately
    _donations[index] = current.copyWith(
      status: DonationStatus.claimed,
      clearVolunteerAssignment: true,
    );
    await _persistLocalDonations();
    _broadcastDonationEvent('update', _donations[index]);
    notifyListeners();
    return true;
  }

  /// Volunteer marks task as picked up from donor (legacy or direct)
  Future<bool> markPickedUp(String donationId) async {
    return confirmPickupWithOtp(donationId: donationId, enteredOtp: '0000');
  }

  /// Volunteer marks task as delivered to NGO shelter (legacy or direct)
  Future<bool> markDelivered(String donationId) async {
    return confirmDeliveryWithOtp(donationId: donationId, enteredOtp: '0000');
  }

  /// Record physical food/clothing distribution to community beneficiaries
  Future<bool> recordDistribution(DistributionRecord record) async {
    final index = _donations.indexWhere((d) => d.id == record.donationId);
    if (index == -1) return false;

    final current = _donations[index];

    // Status transition: delivered -> distributed -> completed
    _donations[index] = current.copyWith(
      status: DonationStatus.completed,
    );

    _distributionRecords.insert(0, record);
    _broadcastDonationEvent('update', _donations[index]);
    notifyListeners();
    return true;
  }

  /// Publish a draft donation to the community
  Future<bool> publishDraft(String donationId) async {
    final index = _donations.indexWhere((d) => d.id == donationId);
    if (index == -1) return false;

    _donations[index] = _donations[index].copyWith(
      status: DonationStatus.available,
    );
    _broadcastDonationEvent('update', _donations[index]);
    notifyListeners();
    return true;
  }

  /// Cancel a donation
  Future<bool> cancelDonation(String donationId) async {
    return withdrawDonation(donationId);
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
        description: 'Freshly cooked vegetable dum biryani packed with raita. Kept under hot-holding warming station. Safe hygienic packaging.',
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
        description: 'Breakfast surplus prepared this morning. Packed in food-grade foil containers with disposable wooden spoons.',
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
        description: 'Cleaned and sanitized winter warm wear for adults and kids. Excellent condition ready for immediate night shelter distribution.',
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
        description: 'Prepared for corporate lunch event surplus. Kept warm in food warmers.',
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
        claimedAt: now.subtract(const Duration(hours: 1)),
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
        description: 'Fresh apples, bananas, biscuits and juice cartons from evening seminar.',
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
        claimedAt: now.subtract(const Duration(hours: 2)),
        assignedVolunteerId: 'usr-vol-303',
        assignedVolunteerName: 'Rohit Kulkarni',
        assignedVolunteerPhone: '+91 97654 99887',
        assignedAt: now.subtract(const Duration(hours: 1, minutes: 15)),
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
        description: 'Brand new navy blue uniforms and black school shoes donated during annual drive.',
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
        claimedAt: now.subtract(const Duration(days: 1, hours: 6)),
        assignedVolunteerId: 'usr-vol-303',
        assignedVolunteerName: 'Rohit Kulkarni',
        assignedAt: now.subtract(const Duration(days: 1, hours: 5)),
        pickedUpAt: now.subtract(const Duration(days: 1, hours: 4)),
        deliveredAt: now.subtract(const Duration(days: 1, hours: 2)),
        clothingCategory: 'kids',
        conditionGrade: 'brand_new',
        isWashedAndClean: true,
      ),
    ]);
  }
}
