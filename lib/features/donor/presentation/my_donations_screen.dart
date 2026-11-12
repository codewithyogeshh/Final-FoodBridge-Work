import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../../../core/widgets/fb_status_chip.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({super.key});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final donationProvider = context.watch<DonationProvider>();
    final donorId = auth.user?.id ?? 'usr-donor-101';

    final allMyDonations = donationProvider.getDonationsByDonor(donorId);
    final activeDonations = allMyDonations
        .where((d) =>
            d.status == DonationStatus.listed ||
            d.status == DonationStatus.claimed ||
            d.status == DonationStatus.assigned ||
            d.status == DonationStatus.pickedUp)
        .toList();
    final historyDonations = allMyDonations
        .where((d) =>
            d.status == DonationStatus.delivered ||
            d.status == DonationStatus.cancelled ||
            d.status == DonationStatus.expired)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.mutedGrey,
          indicatorColor: AppColors.primaryGreen,
          tabs: [
            Tab(text: 'Active Listings (${activeDonations.length})'),
            Tab(text: 'History (${historyDonations.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Donation'),
        onPressed: () => context.push('/create-donation'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDonationList(activeDonations, 'No Active Listings', true),
          _buildDonationList(historyDonations, 'No Donation History', false),
        ],
      ),
    );
  }

  Widget _buildDonationList(List<Donation> list, String emptyTitle, bool isActive) {
    if (list.isEmpty) {
      return FBEmptyState(
        title: emptyTitle,
        description: isActive
            ? 'You do not have any active food or clothing surplus listings.'
            : 'Completed and historical deliveries will appear here.',
        icon: Icons.inventory_2_outlined,
        actionLabel: isActive ? 'Post a Donation' : null,
        onAction: isActive ? () => context.push('/create-donation') : null,
      );
    }

    final dateFormat = DateFormat('EEE, d MMM • hh:mm a');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final d = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/donation-detail/${d.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: d.isFood
                              ? AppColors.primaryGreen.withOpacity(0.12)
                              : AppColors.warningOrange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          d.isFood ? Icons.restaurant : Icons.checkroom,
                          color: d.isFood ? AppColors.primaryGreen : AppColors.warningOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${d.quantity.toStringAsFixed(0)} ${d.unit} • ${d.pickupAddress}',
                              style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
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
                      Text(
                        dateFormat.format(d.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
