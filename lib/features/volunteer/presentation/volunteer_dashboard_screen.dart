import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/exit_confirmation_dialog.dart';
import '../../../core/widgets/scooter_courier_illustration.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';
import '../../notifications/presentation/notification_provider.dart';
import 'widgets/volunteer_bottom_nav.dart';

/// Screen 2: Volunteer Home Dashboard
/// Exact UI matching Top Row Screen 2 of reference mockup.
class VolunteerDashboardScreen extends StatelessWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final donationProvider = context.watch<DonationProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final activeTasks = donationProvider.allDonations
        .where((d) =>
            d.status == DonationStatus.assignedForPickup ||
            d.status == DonationStatus.assigned ||
            d.status == DonationStatus.pickedUp)
        .toList();
    final nextTask = activeTasks.isNotEmpty ? activeTasks.first : null;

    return FoodBridgeExitScope(
      child: Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hamburger Menu
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, size: 22),
                      color: isDark ? Colors.white : AppColors.charcoal,
                      onPressed: () => context.push('/volunteer/profile'),
                    ),
                  ),

                  // Notification Bell with Badge '3'
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined, size: 22),
                          color: isDark ? Colors.white : AppColors.charcoal,
                          onPressed: () => context.push('/notifications'),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE74C3C),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${notificationProvider.unreadCount > 0 ? notificationProvider.unreadCount : 3}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Header
                    Text(
                      context.tr.get('hello_volunteer'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.deepGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Make a difference today!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3 Stat Cards Row (12 Tasks Done, 28h Hours, 4.8 Rating)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: Icons.check,
                            iconColor: AppColors.primaryGreen,
                            iconBg: AppColors.primaryGreen.withOpacity(0.12),
                            value: '12',
                            label: context.tr.get('tasks_done'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: Icons.access_time,
                            iconColor: AppColors.orange,
                            iconBg: AppColors.orange.withOpacity(0.12),
                            value: '28h',
                            label: context.tr.get('hours'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            icon: Icons.star,
                            iconColor: const Color(0xFFF39C12),
                            iconBg: const Color(0xFFF39C12).withOpacity(0.12),
                            value: '4.8',
                            label: context.tr.get('rating'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Hero Next Task Banner with Delivery Scooter
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : null,
                        border: isDark ? Border.all(color: AppColors.borderDark) : null,
                        gradient: isDark
                            ? null
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF0F4D2E), // Deep Emerald
                                  Color(0xFF1E824C), // Primary Green
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Next Task',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  nextTask != null ? nextTask.title : 'Food Pickup',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 14, color: Colors.white.withOpacity(0.85)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        nextTask != null
                                            ? '${nextTask.pickupAddress} (${nextTask.city})'
                                            : 'Claimed orders ready to pickup',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (nextTask != null) {
                                        context.push('/volunteer/tracking');
                                      } else {
                                        context.push('/volunteer/tasks');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(120, 36),
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.deepGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          nextTask != null ? 'View Details' : 'Browse Tasks',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward, size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const ScooterCourierIllustration(size: 110),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions Section
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionItem(
                            context: context,
                            icon: Icons.assignment_outlined,
                            label: 'View\nTasks',
                            onTap: () => context.push('/volunteer/tasks'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionItem(
                            context: context,
                            icon: Icons.timeline,
                            label: 'My\nActivity',
                            onTap: () => context.push('/volunteer/activity'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionItem(
                            context: context,
                            icon: Icons.local_shipping_outlined,
                            label: 'Track\nDeliveries',
                            onTap: () => context.push('/volunteer/tracking'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionItem(
                            context: context,
                            icon: Icons.location_city_outlined,
                            label: 'Nearby\nNGOs',
                            onTap: () => context.push('/ngo'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Upcoming Tasks Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr.get('upcoming_tasks'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepGreen,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/volunteer/tasks'),
                          child: const Row(
                            children: [
                              Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward, size: 14, color: AppColors.primaryGreen),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Upcoming Task Item Card (MG Road)
                    _buildUpcomingTaskCard(
                      context: context,
                      title: 'Food Pickup',
                      location: 'MG Road',
                      time: 'Today • 6:00 PM',
                      icon: Icons.ramen_dining,
                      onTap: () => context.push('/volunteer/tracking'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Additional Active Task if any from state
                    if (activeTasks.isNotEmpty) ...[
                      ...activeTasks.map((t) => _buildUpcomingTaskCard(
                            context: context,
                            title: t.title,
                            location: t.pickupAddress,
                            time: 'Today • In Progress',
                            icon: Icons.fastfood,
                            onTap: () => context.push('/volunteer/tracking'),
                            isDark: isDark,
                          )),
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const VolunteerBottomNav(currentIndex: 0),
    ),
  );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.mutedGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: isDark ? Colors.white : AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTaskCard({
    required BuildContext context,
    required String title,
    required String location,
    required String time,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.orange, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mutedGrey),
            ],
          ),
        ),
      ),
    );
  }
}
