import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          _NotificationTile(
            title: 'Donation Claimed!',
            message: 'Annapoorna Shelter claimed 35 kg of Cooked Food.',
            time: '2 mins ago',
            icon: Icons.check_circle_outline,
            isUnread: true,
          ),
          _NotificationTile(
            title: 'Volunteer Assigned',
            message: 'Rahul P. has been dispatched to collect your donation.',
            time: '12 mins ago',
            icon: Icons.two_wheeler,
            isUnread: true,
          ),
          _NotificationTile(
            title: 'Donation Published',
            message: 'Your listing "35 kg Surplus Banquet Biryani" is now live.',
            time: '25 mins ago',
            icon: Icons.upload_file,
            isUnread: false,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isUnread;

  const _NotificationTile({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUnread ? AppColors.warmCream.withOpacity(0.5) : AppColors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(time, style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
