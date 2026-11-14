import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/exit_confirmation_dialog.dart';
import '../../../core/widgets/fb_appearance_selector.dart';
import '../../../core/widgets/silver_cloche_illustration.dart';
import '../../authentication/presentation/auth_provider.dart';

/// The official Restaurant Donor Dashboard Screen (Matching Image 1 Screen 4 & Image 3 Screen 6).
/// Features:
/// - Dark green hero card with big "48 Total Donations" and the custom Silver Cloche illustration
/// - 4 stat metric cards (2.8K People, 312 kg Food, 12 Active Orders, 98% Success Rate)
/// - Quick Actions: Post Food, View Orders, Analytics
/// - Recent Activity list with food thumbnails
/// - Curved modern bottom navigation bar
class RestaurantDonorDashboardScreen extends StatefulWidget {
  const RestaurantDonorDashboardScreen({super.key});

  @override
  State<RestaurantDonorDashboardScreen> createState() => _RestaurantDonorDashboardScreenState();
}

class _RestaurantDonorDashboardScreenState extends State<RestaurantDonorDashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tr = context.tr;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = auth.user;

    return FoodBridgeExitScope(
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
            child: const Icon(Icons.restaurant, color: AppColors.primaryGreen, size: 20),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restaurant Donor',
              style: TextStyle(fontSize: 11, color: AppColors.mutedGrey, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  currentUser?.organizationName ?? 'Ristorante Paradise',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepGreen,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.deepGreen, size: 18),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: tr.language,
            onPressed: () => showLanguageBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: tr.notifications,
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dark Green Hero Card with Silver Cloche Illustration
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F4D2E), // Deep lush emerald
                    Color(0xFF1E824C), // Primary vibrant green
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
                        Text(
                          'Total Donations',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '48',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            '98% Rescue Rate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SilverClocheIllustration(size: 90),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4 Stat Metric Cards (2x2 Grid)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.55,
              children: [
                _metricCard(
                  icon: Icons.people_outline,
                  value: '2.8K',
                  label: 'People Helped',
                  isDark: isDark,
                ),
                _metricCard(
                  icon: Icons.scale_outlined,
                  value: '312 kg',
                  label: 'Food Saved',
                  isDark: isDark,
                ),
                _metricCard(
                  icon: Icons.receipt_long_outlined,
                  value: '12',
                  label: 'Active Orders',
                  isDark: isDark,
                ),
                _metricCard(
                  icon: Icons.verified_outlined,
                  value: '98%',
                  label: 'Success Rate',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions Header
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
                  child: _quickActionButton(
                    icon: Icons.volunteer_activism_outlined,
                    label: 'Post Food',
                    color: AppColors.primaryGreen,
                    onTap: () => context.push(
                      '/donate-food?title=Cooked+Meals+(Buffet+Surplus)&qty=25&desc=Freshly+cooked+hygienic+restaurant+meals+packed+in+food-grade+boxes',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickActionButton(
                    icon: Icons.receipt_outlined,
                    label: 'View Orders',
                    color: AppColors.orange,
                    onTap: () => context.push('/donor/my-donations'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickActionButton(
                    icon: Icons.bar_chart_outlined,
                    label: 'Analytics',
                    color: AppColors.deepGreen,
                    onTap: () => context.push('/analytics'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // Motivational Banner "Your contribution feeds hope"
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : const Color(0xFFFFF8ED),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDE8CC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, color: AppColors.orange, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your contribution feeds hope ❤️',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.charcoal,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Robin Hood Army and Feeding India volunteers stand ready for pickup.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // Recent Activity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepGreen,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/donor/my-donations'),
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 14, color: AppColors.primaryGreen),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _activityItem(
              title: 'Food Donation',
              subtitle: '2h ago • 25 Food Packets',
              status: 'In Transit',
              statusColor: AppColors.orange,
              icon: Icons.takeout_dining,
              isDark: isDark,
              onTap: () => context.push('/tracking/dn-101'),
            ),
            const SizedBox(height: 10),
            _activityItem(
              title: 'Order Completed',
              subtitle: '3h ago • 50 Meals',
              status: 'Delivered',
              statusColor: AppColors.primaryGreen,
              icon: Icons.check_circle_outline,
              isDark: isDark,
              onTap: () => context.push('/tracking/dn-102'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
  }

  Widget _metricCard({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGreen),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
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

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityItem({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (idx) {
          setState(() => _navIndex = idx);
          if (idx == 0) {
            // Already here
          } else if (idx == 1) {
            context.push('/donor/my-donations');
          } else if (idx == 2) {
            context.push('/analytics');
          } else if (idx == 3) {
            context.push('/profile');
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.mutedGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
