import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/avatar_image_helper.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../notifications/presentation/notification_provider.dart';
import 'widgets/volunteer_bottom_nav.dart';

/// Screen 7: Volunteer Profile Screen
/// Matches Bottom Row Screen 3 of reference mockup.
class VolunteerProfileScreen extends StatelessWidget {
  const VolunteerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final user = auth.user;

    final avatarProvider = AvatarImageHelper.resolve(user?.avatarUrl);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/volunteer'),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 14),

            // Profile Avatar with Green Ring Border and Edit Overlay
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => context.push('/profile/edit'),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGreen, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFEDF7EE),
                        backgroundImage: avatarProvider,
                        child: avatarProvider == null
                            ? const Icon(Icons.person, size: 48, color: AppColors.primaryGreen)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => context.push('/profile/edit'),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Name & Title
            Text(
              user?.fullName ?? 'Volunteer Rider',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'FoodBridge Volunteer',
              style: TextStyle(fontSize: 13, color: AppColors.mutedGrey),
            ),
            if (user?.phone != null || user?.email != null) ...[
              const SizedBox(height: 2),
              Text(
                user?.phone ?? user?.email ?? '',
                style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
              ),
            ],
            const SizedBox(height: 8),

            // Top Volunteer Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: Color(0xFFF39C12)),
                  SizedBox(width: 4),
                  Text(
                    'Top Volunteer',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 3 Stat Cards (12 Tasks, 28h Hours, 4.8 Rating)
            Row(
              children: [
                Expanded(
                  child: _buildSmallStatCard('12', 'Tasks', isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallStatCard('28h', 'Hours', isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallStatCard('4.8 ⭐', 'Rating', isDark),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Menu Items List Container
            Material(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(22),
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      iconBg: const Color(0xFFE8F5E9),
                      iconColor: AppColors.primaryGreen,
                      title: 'Edit Profile (प्रोफाइल संपादित करा)',
                      onTap: () => context.push('/profile/edit'),
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.timeline,
                      iconBg: const Color(0xFFEDF7EE),
                      iconColor: AppColors.primaryGreen,
                      title: 'My Activity',
                      onTap: () => context.push('/volunteer/activity'),
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.notifications_none,
                      iconBg: const Color(0xFFFFF4E5),
                      iconColor: AppColors.orange,
                      title: 'Notifications',
                      badge: notificationProvider.unreadCount > 0
                          ? '${notificationProvider.unreadCount}'
                          : null,
                      onTap: () => context.push('/notifications'),
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.emoji_events_outlined,
                      iconBg: const Color(0xFFFFF8E7),
                      iconColor: const Color(0xFFF39C12),
                      title: 'Rewards & Milestones',
                      onTap: () => context.push('/volunteer/rewards'),
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      iconBg: const Color(0xFFF1F5F9),
                      iconColor: const Color(0xFF475569),
                      title: 'Help & Support',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Volunteer Helpdesk'),
                            content: const Text(
                              'Need immediate help during a food rescue or delivery?\n\n'
                              '• Hotline: 1800-419-FOOD\n'
                              '• WhatsApp Support: +91 98200 55443\n'
                              '• Safe food transport guide is available in your resources tab.',
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      iconBg: const Color(0xFFF1F5F9),
                      iconColor: const Color(0xFF475569),
                      title: 'About FoodBridge',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'FoodBridge',
                          applicationVersion: '2.0.0',
                          applicationLegalese: '© 2026 FoodBridge Foundation. Together for a Hunger-Free Tomorrow.',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const VolunteerBottomNav(currentIndex: 4),
    );
  }

  Widget _buildSmallStatCard(String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFFE74C3C),
                shape: BoxShape.circle,
              ),
              child: Text(
                badge,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.mutedGrey),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 18,
      endIndent: 18,
      color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
    );
  }
}
