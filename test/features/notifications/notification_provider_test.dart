import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/notifications/domain/models/app_notification.dart';
import 'package:foodbridge/features/notifications/presentation/notification_provider.dart';

void main() {
  group('NotificationProvider & Realtime Events Tests (SDLC Phase 9)', () {
    late NotificationProvider provider;

    setUp(() {
      provider = NotificationProvider();
    });

    test('Initial seeded state contains unread notifications', () {
      expect(provider.allNotifications.isNotEmpty, isTrue);
      expect(provider.unreadCount, greaterThan(0));
    });

    test('Dispatches all 10 realtime events properly', () {
      final events = [
        NotificationType.newDonation,
        NotificationType.ngoRequest,
        NotificationType.requestAccepted,
        NotificationType.requestRejected,
        NotificationType.volunteerAssigned,
        NotificationType.pickupConfirmed,
        NotificationType.deliveryConfirmed,
        NotificationType.donationCompleted,
        NotificationType.donationCancelled,
        NotificationType.deadlineWarning,
      ];

      for (int i = 0; i < events.length; i++) {
        final success = provider.dispatchRealtimeEvent(
          title: 'Event Title #$i',
          message: 'Realtime update payload for event ${events[i].name}',
          type: events[i],
          relatedDonationId: 'dn-event-$i',
        );
        expect(success, isTrue);
        expect(provider.allNotifications.first.type, events[i]);
      }
    });

    test('Deduplication guard suppresses repeated identical notifications', () {
      final firstSend = provider.dispatchRealtimeEvent(
        title: 'Duplicate Test',
        message: 'Same payload',
        type: NotificationType.pickupConfirmed,
        relatedDonationId: 'dn-dup-1',
      );
      expect(firstSend, isTrue);

      final secondSend = provider.dispatchRealtimeEvent(
        title: 'Duplicate Test',
        message: 'Same payload',
        type: NotificationType.pickupConfirmed,
        relatedDonationId: 'dn-dup-1',
      );
      // Deduplication must suppress second duplicate event
      expect(secondSend, isFalse);
    });

    test('User preferences: disabled deadline alerts suppresses deadline notifications', () {
      provider.updatePreferences(
        provider.preferences.copyWith(deadlineAlerts: false),
      );

      final dispatched = provider.dispatchRealtimeEvent(
        title: 'Urgent Expiry Alert',
        message: 'Your food listing will expire in 2 hours',
        type: NotificationType.deadlineWarning,
        relatedDonationId: 'dn-urgent-9',
      );

      // Must be suppressed due to user preference
      expect(dispatched, isFalse);
    });

    test('Mark as read and mark all as read updates read state', () {
      expect(provider.unreadCount, greaterThan(0));

      final firstUnread = provider.unreadNotifications.first;
      provider.markAsRead(firstUnread.id);
      expect(provider.allNotifications.firstWhere((n) => n.id == firstUnread.id).isRead, isTrue);

      provider.markAllAsRead();
      expect(provider.unreadCount, 0);
    });
  });
}
