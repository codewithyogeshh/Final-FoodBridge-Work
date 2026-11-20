import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/donation_image_widget.dart';
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

  void _showDonationTypeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Donation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepGreen),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select category to proceed with instant donation posting',
                style: TextStyle(color: AppColors.mutedGrey, fontSize: 13),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.4)),
                ),
                tileColor: AppColors.primaryGreen.withOpacity(0.06),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.soup_kitchen, color: Colors.white),
                ),
                title: const Text('Donate Food Surplus', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Cooked meals, groceries, bakery & fruits'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.primaryGreen),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  context.push('/donate-food');
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.orange.withOpacity(0.4)),
                ),
                tileColor: AppColors.orange.withOpacity(0.06),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.checkroom, color: Colors.white),
                ),
                title: const Text('Donate Clothes', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Wearable clothes, winter wear & blankets'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.orange),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  context.push('/donate-clothes');
                },
              ),
            ],
          ),
        ),
      ),
    );
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

    final tr = context.tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.myDonations),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.mutedGrey,
          indicatorColor: AppColors.primaryGreen,
          tabs: [
            Tab(text: '${tr.get('active_tab')} (${activeDonations.length})'),
            Tab(text: '${tr.get('completed_tab')} (${historyDonations.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(tr.newDonation),
        onPressed: () => _showDonationTypeSheet(context),
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
        onAction: isActive ? () => _showDonationTypeSheet(context) : null,
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: DonationImageWidget(
                            imageUrl: d.imageUrl,
                            isFood: d.isFood,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
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
                      FBStatusChip(
                        status: (d.isDelivered || d.deliveredAt != null)
                            ? 'delivered_to_ngo'
                            : (d.isExpired ? 'expired' : d.status.name),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          dateFormat.format(d.createdAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
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

