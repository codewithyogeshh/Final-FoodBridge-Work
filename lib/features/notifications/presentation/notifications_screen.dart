import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../domain/models/app_notification.dart';
import 'notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _filterUnreadOnly = false;

  void _showPreferencesSheet(BuildContext context) {
    final notifProvider = context.read<NotificationProvider>();
    var prefs = notifProvider.preferences;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Notification Preferences',
                        style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
              const Divider(),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive instant alerts on your device'),
                value: prefs.pushEnabled,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: (val) {
                  setSheetState(() => prefs = prefs.copyWith(pushEnabled: val));
                  notifProvider.updatePreferences(prefs);
                },
              ),
              SwitchListTile(
                title: const Text('Urgent Deadline Alerts'),
                subtitle: const Text('Alert when food is within 2 hours of expiry'),
                value: prefs.deadlineAlerts,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: (val) {
                  setSheetState(() => prefs = prefs.copyWith(deadlineAlerts: val));
                  notifProvider.updatePreferences(prefs);
                },
              ),
              SwitchListTile(
                title: const Text('Nearby Donation Rescues'),
                subtitle: const Text('Alert when new food surplus is posted in your area'),
                value: prefs.nearbyDonationsAlerts,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: (val) {
                  setSheetState(() => prefs = prefs.copyWith(nearbyDonationsAlerts: val));
                  notifProvider.updatePreferences(prefs);
                },
              ),
              SwitchListTile(
                title: const Text('Live Status Changes'),
                subtitle: const Text('Alerts on claims, pickup & delivery confirmations'),
                value: prefs.statusChangeAlerts,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: (val) {
                  setSheetState(() => prefs = prefs.copyWith(statusChangeAlerts: val));
                  notifProvider.updatePreferences(prefs);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final all = notifProvider.allNotifications;
    final displayList = _filterUnreadOnly
        ? notifProvider.unreadNotifications
        : all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Notification Preferences',
            onPressed: () => _showPreferencesSheet(context),
          ),
          if (notifProvider.unreadCount > 0)
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('All (${all.length})'),
                  selected: !_filterUnreadOnly,
                  selectedColor: AppColors.primaryGreen.withValues(alpha: 0.18),
                  labelStyle: TextStyle(
                    color: !_filterUnreadOnly ? AppColors.deepGreen : AppColors.mutedGrey,
                    fontWeight: !_filterUnreadOnly ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _filterUnreadOnly = false);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Unread (${notifProvider.unreadCount})'),
                  selected: _filterUnreadOnly,
                  selectedColor: AppColors.primaryGreen.withValues(alpha: 0.18),
                  labelStyle: TextStyle(
                    color: _filterUnreadOnly ? AppColors.deepGreen : AppColors.mutedGrey,
                    fontWeight: _filterUnreadOnly ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _filterUnreadOnly = true);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Notification List
          Expanded(
            child: displayList.isEmpty
                ? FBEmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: _filterUnreadOnly ? 'No Unread Notifications' : 'No Notifications Yet',
                    description: 'You are all caught up! Realtime status updates and urgent rescue alerts will appear here.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      return _NotificationCard(
                        item: item,
                        onTap: () {
                          notifProvider.markAsRead(item.id);
                          if (item.actionRoute != null) {
                            context.push(item.actionRoute!);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.item,
    required this.onTap,
  });

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.newDonation:
        return Icons.soup_kitchen_outlined;
      case NotificationType.ngoRequest:
        return Icons.handshake_outlined;
      case NotificationType.requestAccepted:
        return Icons.check_circle_outline;
      case NotificationType.requestRejected:
        return Icons.cancel_outlined;
      case NotificationType.volunteerAssigned:
        return Icons.two_wheeler_outlined;
      case NotificationType.pickupConfirmed:
        return Icons.archive_outlined;
      case NotificationType.deliveryConfirmed:
        return Icons.unarchive_outlined;
      case NotificationType.donationCompleted:
        return Icons.task_alt;
      case NotificationType.donationCancelled:
        return Icons.block;
      case NotificationType.deadlineWarning:
        return Icons.timer_outlined;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.deadlineWarning:
        return AppColors.errorRed;
      case NotificationType.requestRejected:
      case NotificationType.donationCancelled:
        return AppColors.warningOrange;
      default:
        return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('hh:mm a');
    final color = _getColorForType(item.type);

    return Card(
      color: item.isRead ? Colors.white : AppColors.warmCream.withValues(alpha: 0.5),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.isRead ? AppColors.borderLight : color.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIconForType(item.type), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        Text(
                          dateFormat.format(item.timestamp),
                          style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey, height: 1.3),
                    ),
                  ],
                ),
              ),
              if (!item.isRead) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
