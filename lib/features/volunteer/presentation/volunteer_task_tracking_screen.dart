import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/route_map_view.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';
import 'widgets/volunteer_bottom_nav.dart';

/// Screen 4: Volunteer Task Tracking
/// Real-time live route tracking matching reference mockup
class VolunteerTaskTrackingScreen extends StatefulWidget {
  const VolunteerTaskTrackingScreen({super.key});

  @override
  State<VolunteerTaskTrackingScreen> createState() => _VolunteerTaskTrackingScreenState();
}

class _VolunteerTaskTrackingScreenState extends State<VolunteerTaskTrackingScreen> {
  bool _isCompleted = false;

  void _onMarkAsCompleted(Donation? task, DonationProvider provider) async {
    setState(() => _isCompleted = true);

    if (task != null) {
      await provider.confirmDeliveryWithOtp(
        donationId: task.id,
        enteredOtp: task.deliveryOtp,
      );
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 28),
            SizedBox(width: 10),
            Text('Mission Completed!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          task != null
              ? 'Great job! You helped rescue ${task.quantity.toInt()} ${task.unit} from ${task.donorName}. +50 Karma Points awarded to your profile.'
              : 'Great job! You helped rescue 20 hot meals from Hotel Grand Plaza. +50 Karma Points awarded to your profile.',
          style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/volunteer/activity');
            },
            child: const Text('View Activity', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/volunteer');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final donationProvider = context.watch<DonationProvider>();
    final auth = context.watch<AuthProvider>();
    final volunteerId = auth.user?.id ?? 'usr-vol-301';

    final activeTasks = donationProvider.getVolunteerActiveTasks(volunteerId);
    final Donation? currentTask = activeTasks.isNotEmpty ? activeTasks.first : null;

    final title = currentTask?.title ?? 'Food Pickup';
    final location = currentTask != null ? '${currentTask.pickupAddress} (${currentTask.city})' : 'Hotel Grand Plaza';
    final donorName = currentTask?.donorName ?? 'Grand Plaza';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/volunteer'),
        ),
        title: const Text(
          'Task Tracking',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.near_me_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Full Screen Interactive Route Map View
          Positioned.fill(
            child: RouteMapView(
              etaText: 'ETA: 15 min • 2.4 km',
              pickupAddress: location,
              destinationAddress: currentTask?.dropoffAddress ?? 'Slum Feeding Point (Swargate)',
            ),
          ),

          // 2. Top Floating Card
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.ramen_dining, color: AppColors.orange, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          location,
                          style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        const Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: AppColors.primaryGreen),
                            SizedBox(width: 4),
                            Text(
                              'ETA: 15 min • 2.4 km',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isCompleted ? 'Completed' : 'In Progress',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Floating Action Card
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF7EE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.soup_kitchen, color: AppColors.primaryGreen, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Restaurant',
                              style: TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                            ),
                            Text(
                              donorName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.phone, size: 20, color: AppColors.deepGreen),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling $donorName...')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Wide Green Button: "Mark as Completed ✓"
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _onMarkAsCompleted(currentTask, donationProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mark as Completed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const VolunteerBottomNav(currentIndex: 1),
    );
  }
}
