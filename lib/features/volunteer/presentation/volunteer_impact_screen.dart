import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/community_silhouettes_illustration.dart';
import '../../../core/widgets/foodbridge_logo.dart';
import 'widgets/volunteer_bottom_nav.dart';

/// Screen 6: Volunteer Impact Screen
/// Matches Bottom Row Screen 2 of reference mockup.
class VolunteerImpactScreen extends StatelessWidget {
  const VolunteerImpactScreen({super.key});

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
          'Your Impact',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Top Hero Emerald Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0F4D2E), // Deep emerald
                              Color(0xFF1E824C), // Primary green
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Heart Logo
                            const FoodBridgeLogo(
                              size: 44,
                              isLight: true,
                              showTagline: false,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Together we made a difference!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 3 Impact Metric Columns
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildImpactMetric('245', 'Meals Saved'),
                                Container(
                                  width: 1,
                                  height: 38,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                                _buildImpactMetric('18', 'People Helped'),
                                Container(
                                  width: 1,
                                  height: 38,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                                _buildImpactMetric('25 kg', 'Food Saved'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Middle Thank You Section
                    const Text(
                      'Your Effort Matters 💚',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Thank you for being a part of FoodBridge! Every pickup and delivery helps a family sleep with food and hope.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedGrey,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Button to View Badges & Rewards
                    TextButton.icon(
                      onPressed: () => context.push('/volunteer/rewards'),
                      icon: const Icon(Icons.emoji_events, color: AppColors.orange, size: 20),
                      label: const Text(
                        'View Your Badges & Milestones →',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Community Volunteer Silhouettes Illustration
                    const CommunitySilhouettesIllustration(height: 190),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const VolunteerBottomNav(currentIndex: 3),
    );
  }

  Widget _buildImpactMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
