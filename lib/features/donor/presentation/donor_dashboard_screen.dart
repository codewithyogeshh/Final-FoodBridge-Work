import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../../../core/widgets/fb_status_chip.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/presentation/donation_provider.dart';

class DonorDashboardScreen extends StatelessWidget {
  const DonorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final donationProvider = context.watch<DonationProvider>();
    final currentUser = auth.user;

    // Donor's own donations or all donations if mock donor
    final myDonations = donationProvider.getDonationsByDonor(
      currentUser?.id ?? 'usr-donor-101',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Donation'),
        onPressed: () => context.push('/create-donation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepGreen, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${currentUser?.fullName ?? "Donor"}!',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser?.organizationName ?? 'Community Donor Member',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Have surplus meals or clean clothes tonight? Post a rescue in under 90 seconds.',
                    style: TextStyle(color: AppColors.white, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Donation Action Buttons
            Text(
              'Create a Donation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    title: 'Donate Food',
                    subtitle: 'Cooked, groceries, bakery',
                    icon: Icons.soup_kitchen_outlined,
                    color: AppColors.primaryGreen,
                    onTap: () => context.push('/create-donation'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionTile(
                    title: 'Donate Clothes',
                    subtitle: 'Wearable, clean garments',
                    icon: Icons.checkroom_outlined,
                    color: AppColors.orange,
                    onTap: () => context.push('/create-donation'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Active Donations Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Active Listings (${myDonations.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (myDonations.isEmpty)
              FBEmptyState(
                title: 'No Active Donations',
                description: 'You have not listed any food or clothes recently. Tap "+ New Donation" to start rescuing surplus.',
                icon: Icons.inventory_2_outlined,
                actionLabel: 'Donate Surplus',
                onAction: () => context.push('/create-donation'),
              )
            else
              ...myDonations.map((d) {
                final dateFormat = DateFormat('hh:mm a');
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push('/donation-detail/${d.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: d.isFood
                                      ? AppColors.primaryGreen.withOpacity(0.12)
                                      : AppColors.warningOrange.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  d.isFood ? Icons.restaurant : Icons.checkroom,
                                  color: d.isFood
                                      ? AppColors.primaryGreen
                                      : AppColors.warningOrange,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${d.quantity.toStringAsFixed(0)} ${d.unit} • ${d.pickupAddress}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.mutedGrey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FBStatusChip(status: d.status.name),
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Deadline: ${dateFormat.format(d.pickupDeadline)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24),

            // Impact Counter Cards
            Text(
              'Your Community Impact',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ImpactTile(
                    count: donationProvider.totalMealsRescued.toStringAsFixed(0),
                    label: 'Meals Rescued',
                    icon: Icons.soup_kitchen_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ImpactTile(
                    count: donationProvider.totalClothingItemsRedistributed.toString(),
                    label: 'Clothes Shared',
                    icon: Icons.checkroom_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ImpactTile(
                    count: '${(donationProvider.totalMealsRescued * 2.5).toStringAsFixed(0)} kg',
                    label: 'CO2 Saved',
                    icon: Icons.eco_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.charcoal),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactTile extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;

  const _ImpactTile({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGreen),
          const SizedBox(height: 6),
          Text(
            count,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepGreen),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.mutedGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
