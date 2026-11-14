import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/delivery_truck_illustration.dart';
import '../../../core/widgets/golden_trophy_illustration.dart';
import 'widgets/volunteer_bottom_nav.dart';

/// Screen 8: Volunteer Rewards & Badges Screen
/// Matches Bottom Row Screen 4 of reference mockup.
class VolunteerRewardsScreen extends StatelessWidget {
  const VolunteerRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/volunteer'),
        ),
        title: const Text(
          'Rewards',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Top Hero Trophy Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  GoldenTrophyIllustration(size: 130),
                  SizedBox(height: 12),
                  Text(
                    'Keep Helping, Keep Growing!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepGreen,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your contributions unlock special volunteer milestones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Next Badge Progress Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E5),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.orange, width: 2),
                        ),
                        child: const Icon(Icons.military_tech, color: AppColors.orange, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Badge',
                            style: TextStyle(fontSize: 11, color: AppColors.mutedGrey, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '100 Hours Club',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Progress', style: TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
                      Text(
                        '72 / 100 h',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.72,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFEAF8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // "Your Badges" Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Your Badges',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepGreen,
                  ),
                ),
                Text(
                  '4 Earned',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4 Badges Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBadgeItem(
                  icon: Icons.favorite,
                  iconColor: const Color(0xFFE74C3C),
                  borderColor: const Color(0xFFE74C3C),
                  label: 'First\nRescue',
                  isDark: isDark,
                ),
                _buildBadgeItem(
                  icon: Icons.handshake,
                  iconColor: const Color(0xFF2980B9),
                  borderColor: const Color(0xFF2980B9),
                  label: 'Community\nHero',
                  isDark: isDark,
                ),
                _buildBadgeItem(
                  icon: Icons.star,
                  iconColor: const Color(0xFFF39C12),
                  borderColor: const Color(0xFFF39C12),
                  label: 'Speedy\nDeliverer',
                  isDark: isDark,
                ),
                _buildBadgeItem(
                  icon: Icons.eco,
                  iconColor: AppColors.primaryGreen,
                  borderColor: AppColors.primaryGreen,
                  label: 'Zero Waste\nChampion',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Motivation Banner: "Volunteer Today... Build a Hunger-Free Tomorrow"
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F4D2E), // Deep emerald
                    Color(0xFF1E824C), // Primary green
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Volunteer Today...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Build a Hunger-Free Tomorrow',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFD4EDDA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 70,
                    height: 50,
                    child: DeliveryTruckIllustration(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const VolunteerBottomNav(currentIndex: 4),
    );
  }

  Widget _buildBadgeItem({
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String label,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 26),
          ),
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
    );
  }
}
