import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fb_button.dart';
import '../../../authentication/presentation/auth_provider.dart';
import '../../../donations/domain/models/donation.dart';
import '../../../donations/presentation/donation_provider.dart';

class VolunteerTaskDetailSheet extends StatefulWidget {
  final Donation task;
  final bool isOnline;

  const VolunteerTaskDetailSheet({
    super.key,
    required this.task,
    required this.isOnline,
  });

  static Future<void> show(
    BuildContext context, {
    required Donation task,
    required bool isOnline,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VolunteerTaskDetailSheet(
        task: task,
        isOnline: isOnline,
      ),
    );
  }

  @override
  State<VolunteerTaskDetailSheet> createState() => _VolunteerTaskDetailSheetState();
}

class _VolunteerTaskDetailSheetState extends State<VolunteerTaskDetailSheet> {
  bool _isAccepting = false;
  bool _isAccepted = false;

  Future<void> _handleAcceptTask() async {
    if (!widget.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please switch your status to "Online" before accepting dispatch tasks.'),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    final donationProvider = context.read<DonationProvider>();
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;
    final volunteerId = currentUser?.id ?? 'usr-vol-303';
    final volunteerName = currentUser?.fullName ?? 'Rohit Kulkarni';
    final phone = currentUser?.phone ?? '+91 97654 99887';

    setState(() => _isAccepting = true);

    final success = await donationProvider.acceptVolunteerTask(
      donationId: widget.task.id,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
      phone: phone,
    );

    if (!mounted) return;
    setState(() => _isAccepting = false);

    if (success) {
      setState(() => _isAccepted = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(donationProvider.errorMessage ?? 'Failed to accept task.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.task;
    final dateFormat = DateFormat('hh:mm a, EEE d MMM');
    final aiService = AIService();
    final match = aiService.calculateMatch(donation: d, distanceKm: d.estimatedDistanceKm);
    final advisory = aiService.getSafeHandlingAdvisory(d);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: d.isFood ? AppColors.primaryGreen.withValues(alpha: 0.12) : AppColors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        d.isFood ? Icons.soup_kitchen : Icons.checkroom,
                        size: 14,
                        color: d.isFood ? AppColors.primaryGreen : AppColors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        d.isFood ? 'FOOD RESCUE MISSION' : 'CLOTHING DISPATCH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: d.isFood ? AppColors.primaryGreen : AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              d.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${d.quantity.toStringAsFixed(0)} ${d.unit} • Destination: ${d.claimedByNgoName ?? "Registered Shelter"}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedGrey),
            ),
            const SizedBox(height: 12),

            // AI Match Score Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Route Compatibility: ${match.matchTier}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepGreen),
                        ),
                        Text(
                          match.reason,
                          style: const TextStyle(fontSize: 11, color: AppColors.charcoal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route & Distance Summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warmCream.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.trip_origin, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup Locality: ${d.city}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              _isAccepted
                                  ? d.pickupAddress
                                  : 'Exact street address unlocked immediately upon acceptance.',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isAccepted ? AppColors.deepGreen : AppColors.mutedGrey,
                                fontWeight: _isAccepted ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Divider(),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Drop-off: ${d.claimedByNgoName ?? "NGO Shelter"}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              d.dropoffAddress,
                              style: const TextStyle(fontSize: 12, color: AppColors.charcoal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.near_me, size: 16, color: AppColors.mutedGrey),
                          const SizedBox(width: 4),
                          Text(
                            '~${d.estimatedDistanceKm} km total',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: AppColors.errorRed),
                          const SizedBox(width: 4),
                          Text(
                            'Deadline: ${dateFormat.format(d.pickupDeadline)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.errorRed),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI Safe Handling Advisory
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.health_and_safety_outlined, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        advisory.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.charcoal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...advisory.handlingTips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                            Expanded(
                              child: Text(tip, style: const TextStyle(fontSize: 12, color: AppColors.charcoal)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 6),
                  Text(
                    'Container: ${advisory.recommendedContainer} | Target: ${advisory.maxTransitWindow}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    advisory.disclaimer,
                    style: TextStyle(fontSize: 10, color: AppColors.mutedGrey.withValues(alpha: 0.8), fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (!_isAccepted) ...[
              FBButton.rider(
                label: 'ACCEPT THIS DISPATCH TASK',
                icon: Icons.check_circle_outline,
                isLoading: _isAccepting,
                onPressed: _handleAcceptTask,
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Review Later'),
              ),
            ] else ...[
              // Unlocked view after acceptance
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open, color: AppColors.primaryGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Task Assigned Successfully!',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepGreen),
                          ),
                          Text(
                            'Pickup address and donor contact are now available in your active mission.',
                            style: TextStyle(fontSize: 12, color: AppColors.deepGreen.withValues(alpha: 0.9)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FBButton.rider(
                label: 'START NAVIGATION & LIVE MISSION',
                icon: Icons.navigation_outlined,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/volunteer/mission/${d.id}');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

