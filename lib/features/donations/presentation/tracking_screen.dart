import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/route_map_view.dart';
import 'donation_provider.dart';

/// The official FoodBridge Real-Time Tracking Screen (Matching Image 3 Screen 9).
/// Features:
/// - Stylized interactive route map
/// - Live courier callout: "Pickup in 24 min"
/// - "Your donation is on the way! Arriving by 8:45 PM"
/// - 3-step delivery progress stepper: Picked Up -> In Transit -> Delivered
/// - Courier contact & Emergency Task Release
class TrackingScreen extends StatefulWidget {
  final String donationId;

  const TrackingScreen({
    super.key,
    required this.donationId,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final donationProvider = context.watch<DonationProvider>();
    final donation = donationProvider.getDonationById(widget.donationId);
    final volunteerName = donation?.assignedVolunteerName ?? 'Volunteer Hero';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Courier location updated in real-time.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Interactive Map View
            RouteMapView(
              height: 280,
              etaText: 'Pickup in 24 min',
              onRefresh: () => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Your donation is on the way!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Arriving by 8:45 PM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedGrey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3-Step Horizontal Stepper
                  _buildStepper(),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Assigned Volunteer Card
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF8F0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sports_motorsports,
                          color: AppColors.primaryGreen,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              volunteerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Honda Activa • MH 12 FB 2026',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: AppColors.primaryGreen),
                        tooltip: 'Call Volunteer',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calling volunteer: +91 97654 99887')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Emergency Task Release (Robin Hood Army / Safety protocol)
            OutlinedButton.icon(
              icon: const Icon(Icons.report_problem_outlined, color: AppColors.errorRed, size: 18),
              label: const Text('Emergency Re-Dispatch / Support'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorRed,
                side: const BorderSide(color: AppColors.errorRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Emergency Assistance'),
                    content: const Text(
                      'If the volunteer encounters vehicle breakdown or food safety expiry, tap confirm to return this mission to the community rescue queue.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dispatched alert to nearby volunteers.'),
                              backgroundColor: AppColors.errorRed,
                            ),
                          );
                        },
                        child: const Text('Re-dispatch Task', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepNode(label: 'Picked Up', isDone: true, isActive: false),
        _stepLine(isDone: true),
        _stepNode(label: 'In Transit', isDone: false, isActive: true),
        _stepLine(isDone: false),
        _stepNode(label: 'Delivered', isDone: false, isActive: false),
      ],
    );
  }

  Widget _stepNode({required String label, required bool isDone, required bool isActive}) {
    Color color;
    IconData icon;
    if (isDone) {
      color = AppColors.primaryGreen;
      icon = Icons.check;
    } else if (isActive) {
      color = AppColors.orange;
      icon = Icons.directions_bike;
    } else {
      color = Colors.grey.shade400;
      icon = Icons.circle;
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDone || isActive ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDone || isActive ? Colors.white : color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.charcoal : AppColors.mutedGrey,
          ),
        ),
      ],
    );
  }

  Widget _stepLine({required bool isDone}) {
    return Container(
      width: 48,
      height: 2.5,
      margin: const EdgeInsets.only(bottom: 20),
      color: isDone ? AppColors.primaryGreen : Colors.grey.shade300,
    );
  }
}
