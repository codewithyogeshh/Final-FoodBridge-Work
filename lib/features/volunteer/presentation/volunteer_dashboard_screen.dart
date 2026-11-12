import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final donationProvider = context.watch<DonationProvider>();
    final currentUser = auth.user;

    final volunteerId = currentUser?.id ?? 'usr-vol-303';
    final activeTasks = donationProvider.getVolunteerActiveTasks(volunteerId);
    final availableTasks = donationProvider.volunteerAvailableTasks;
    final completedTasks = donationProvider.getVolunteerCompletedTasks(volunteerId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Dispatch'),
        actions: [
          Row(
            children: [
              Text(
                _isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _isOnline ? AppColors.primaryGreen : AppColors.mutedGrey,
                ),
              ),
              Switch(
                value: _isOnline,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: (val) => setState(() => _isOnline = val),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status and Vehicle Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isOnline ? AppColors.warmCream : AppColors.borderLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isOnline ? AppColors.primaryGreen : AppColors.mutedGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.two_wheeler, color: _isOnline ? AppColors.primaryGreen : AppColors.mutedGrey),
                      const SizedBox(width: 8),
                      Text(
                        'Motorcycle Dispatcher',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isOnline ? AppColors.charcoal : AppColors.mutedGrey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Active: ${activeTasks.length} / Max 2',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: activeTasks.isNotEmpty ? AppColors.orange : AppColors.mutedGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Task View (if accepted)
            if (activeTasks.isNotEmpty) ...[
              Text(
                'YOUR ACTIVE DISPATCH (${activeTasks.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 10),
              ...activeTasks.map((task) {
                final dateFormat = DateFormat('hh:mm a');
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.primaryGreen, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: task.status == DonationStatus.assigned
                                    ? AppColors.warningOrange.withOpacity(0.15)
                                    : AppColors.statusInTransitBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.status == DonationStatus.assigned
                                    ? 'PROCEED TO PICKUP'
                                    : 'IN TRANSIT TO SHELTER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: task.status == DonationStatus.assigned
                                      ? AppColors.warningOrange
                                      : AppColors.statusInTransitText,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 14, color: AppColors.errorRed),
                                const SizedBox(width: 4),
                                Text(
                                  'Collect by ${dateFormat.format(task.pickupDeadline)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.errorRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          task.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${task.quantity.toStringAsFixed(0)} ${task.unit} • Destination: ${task.claimedByNgoName ?? "Shelter"}',
                          style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Private Donor Address Unlocked
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.pickupAddress,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  const Text(
                                    'Pickup Address (Unlocked for this dispatch)',
                                    style: TextStyle(fontSize: 11, color: AppColors.primaryGreen),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (task.donorPhone != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: AppColors.primaryGreen, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Donor: ${task.donorName} (${task.donorPhone})',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Rider Mode Big Action Buttons
                        if (task.status == DonationStatus.assigned) ...[
                          FBButton.rider(
                            label: 'CONFIRM PHYSICAL PICKUP',
                            icon: Icons.check_circle_outline,
                            onPressed: () async {
                              await donationProvider.markPickedUp(task.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pickup recorded! Proceed safely to NGO shelter.'),
                                    backgroundColor: AppColors.primaryGreen,
                                  ),
                                );
                              }
                            },
                          ),
                        ] else ...[
                          FBButton.rider(
                            label: 'CONFIRM HANDOVER TO NGO',
                            icon: Icons.done_all,
                            onPressed: () async {
                              await donationProvider.markDelivered(task.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Delivery completed! Thank you for your service.'),
                                    backgroundColor: AppColors.deepGreen,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () => context.push('/donation-detail/${task.id}'),
                            child: const Text('View Full Donation Specs', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // Open Task Feed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Dispatches (${availableTasks.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (availableTasks.isEmpty)
              const FBEmptyState(
                title: 'No Pending Pickups',
                description: 'All current NGO claims have active couriers or there are no new claims.',
                icon: Icons.two_wheeler_outlined,
              )
            else
              ...availableTasks.map((task) {
                final dateFormat = DateFormat('hh:mm a');
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.statusAvailableBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.isFood ? '🍛 FOOD RESCUE' : '👕 CLOTHES DISPATCH',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.statusAvailableText,
                                ),
                              ),
                            ),
                            Text(
                              'Collect by ${dateFormat.format(task.pickupDeadline)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          task.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.charcoal),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Route: ${task.city} ──► ${task.claimedByNgoName ?? "NGO Shelter"}',
                          style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey),
                        ),
                        const SizedBox(height: 16),
                        FBButton.rider(
                          label: 'ACCEPT DISPATCH TASK',
                          icon: Icons.flash_on,
                          onPressed: () async {
                            await donationProvider.acceptVolunteerTask(
                              donationId: task.id,
                              volunteerId: volunteerId,
                              volunteerName: currentUser?.fullName ?? 'Rohit Kulkarni',
                              phone: currentUser?.phone ?? '+91 97654 99887',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Task locked to you! Ride safely.'),
                                  backgroundColor: AppColors.deepGreen,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24),

            // Completed Dispatches Impact
            if (completedTasks.isNotEmpty) ...[
              Text(
                'Your Completed Deliveries (${completedTasks.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              ...completedTasks.map((t) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.statusAvailableBg,
                        child: Icon(Icons.done_all, color: AppColors.statusAvailableText, size: 20),
                      ),
                      title: Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text('Delivered to ${t.claimedByNgoName}', style: const TextStyle(fontSize: 11)),
                      trailing: const Text('Delivered', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  )),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
