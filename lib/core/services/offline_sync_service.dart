import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/donations/domain/models/donation.dart';

/// Provides offline-first caching for donations and offline sync queue.
/// Allows volunteers and NGOs to view orders and verify deliveries even in zero-network areas.
class OfflineSyncService {
  OfflineSyncService._();
  static final OfflineSyncService instance = OfflineSyncService._();

  static const String _kCachedDonationsKey = 'offline_cached_donations_v1';
  static const String _kOfflineActionsKey = 'offline_actions_queue_v1';

  /// Save donations list to persistent local cache
  Future<void> cacheDonations(List<Donation> donations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = donations.map((d) => d.toJson()).toList();
      await prefs.setString(_kCachedDonationsKey, json.encode(list));
    } catch (e) {
      debugPrint('[OfflineSyncService] Failed to cache donations: $e');
    }
  }

  /// Retrieve cached donations from local persistent storage
  Future<List<Donation>> getCachedDonations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_kCachedDonationsKey);
      if (str != null && str.isNotEmpty) {
        final List<dynamic> list = json.decode(str);
        return list.map((item) => Donation.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[OfflineSyncService] Failed to read cached donations: $e');
    }
    return [];
  }

  /// Queue an action to be executed when back online (e.g. pickup, delivery)
  Future<void> queueOfflineAction({
    required String actionType,
    required String donationId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_kOfflineActionsKey) ?? [];
      final actionItem = json.encode({
        'actionType': actionType,
        'donationId': donationId,
        'data': data ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
      existing.add(actionItem);
      await prefs.setStringList(_kOfflineActionsKey, existing);
      debugPrint('[OfflineSyncService] Action queued for offline sync: $actionType on $donationId');
    } catch (e) {
      debugPrint('[OfflineSyncService] Failed to queue offline action: $e');
    }
  }

  /// Process and replay pending offline actions once connection is restored
  Future<int> replayPendingActions({
    required Future<void> Function(String actionType, String donationId, Map<String, dynamic> data) onSync,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_kOfflineActionsKey) ?? [];
      if (existing.isEmpty) return 0;

      int successful = 0;
      final remaining = <String>[];

      for (final item in existing) {
        try {
          final map = json.decode(item) as Map<String, dynamic>;
          final action = map['actionType'] as String;
          final donationId = map['donationId'] as String;
          final data = map['data'] as Map<String, dynamic>? ?? {};

          await onSync(action, donationId, data);
          successful++;
        } catch (_) {
          remaining.add(item);
        }
      }

      await prefs.setStringList(_kOfflineActionsKey, remaining);
      debugPrint('[OfflineSyncService] Replayed $successful offline actions successfully.');
      return successful;
    } catch (e) {
      debugPrint('[OfflineSyncService] Replay error: $e');
      return 0;
    }
  }
}
