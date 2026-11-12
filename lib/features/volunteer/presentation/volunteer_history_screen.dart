import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/presentation/donation_provider.dart';

class VolunteerHistoryScreen extends StatelessWidget {
  const VolunteerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final donationProvider = context.watch<DonationProvider>();
    final volunteerId = auth.user?.id ?? 'usr-vol-303';

    final completedTasks = donationProvider.getVolunteerCompletedTasks(volunteerId);
    final dateFormat = DateFormat('EEE, d MMM • hh:mm a');

    final mealsDelivered = completedTasks
        .where((t) => t.isFood)
        .fold(0.0, (acc, item) => acc + item.quantity);
    final clothesDelivered = completedTasks
        .where((t) => t.isClothing)
        .fold(0, (acc, item) => acc + item.quantity.toInt());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch History & Impact'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rider Impact Scorecard
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepGreen, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Lifetime Rider Contribution',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${completedTasks.length} Deliveries Completed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricBadge(mealsDelivered.toStringAsFixed(0), 'Meals Rescued'),
                      _metricBadge('$clothesDelivered', 'Garments Handed'),
                      _metricBadge('${(mealsDelivered * 2.5).toStringAsFixed(0)} kg', 'CO₂ Prevented'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Past Delivery Trips (${completedTasks.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            if (completedTasks.isEmpty)
              const FBEmptyState(
                title: 'No Completed Deliveries Yet',
                description: 'Accept dispatches from the Volunteer feed to start building your community impact score!',
                icon: Icons.two_wheeler_outlined,
              )
            else
              ...completedTasks.map((t) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push('/donation-detail/${t.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                                child: Icon(
                                  t.isFood ? Icons.restaurant : Icons.checkroom,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      'Delivered to: ${t.claimedByNgoName ?? "Shelter"}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.verified, color: AppColors.primaryGreen, size: 20),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${t.quantity.toStringAsFixed(0)} ${t.unit} transported',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepGreen,
                                ),
                              ),
                              Text(
                                t.deliveredAt != null
                                    ? dateFormat.format(t.deliveredAt!)
                                    : 'Completed',
                                style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _metricBadge(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}
