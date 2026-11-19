import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/presentation/donation_provider.dart';
import 'widgets/volunteer_bottom_nav.dart';

/// Screen 5: Volunteer Activity & History Timeline
/// Matches reference mockup while binding to live completed delivery history
class VolunteerActivityScreen extends StatefulWidget {
  const VolunteerActivityScreen({super.key});

  @override
  State<VolunteerActivityScreen> createState() => _VolunteerActivityScreenState();
}

class _VolunteerActivityScreenState extends State<VolunteerActivityScreen> {
  String _selectedTab = 'all'; // 'all', 'donations', 'deliveries'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final donationProvider = context.watch<DonationProvider>();
    final auth = context.watch<AuthProvider>();
    final volunteerId = auth.user?.id ?? 'usr-vol-301';

    final liveCompleted = donationProvider.getVolunteerCompletedTasks(volunteerId);
    final liveActive = donationProvider.getVolunteerActiveTasks(volunteerId);
    final hasLiveData = liveCompleted.isNotEmpty || liveActive.isNotEmpty;

    final dateFormat = DateFormat('dd MMM, hh:mm a');

    final mockActivities = [
      _ActivityItemData(
        title: 'Food Pickup Completed',
        location: 'Hotel Grand Plaza',
        time: 'Today • 7:15 PM',
        tag: '+50 pts',
        type: 'donations',
        isDelivered: true,
      ),
      _ActivityItemData(
        title: 'Delivery Completed',
        location: 'Sadar Bazar, Satara',
        time: 'Yesterday • 6:20 PM',
        tag: '+50 pts',
        type: 'deliveries',
        isDelivered: true,
      ),
      _ActivityItemData(
        title: 'Task Accepted',
        location: 'Cafe Delight',
        time: 'Yesterday • 4:30 PM',
        tag: 'In Progress',
        type: 'donations',
        isDelivered: false,
      ),
      _ActivityItemData(
        title: 'Clothing Drive Distributed',
        location: 'Swargate Orphanage Center',
        time: '3 days ago • 11:30 AM',
        tag: '+75 pts',
        type: 'deliveries',
        isDelivered: true,
      ),
    ];

    final displayItems = hasLiveData
        ? [
            ...liveCompleted.map((d) => _ActivityItemData(
                  title: 'Delivery Completed: ${d.title}',
                  location: 'To: ${d.claimedByNgoName ?? 'Shelter'}',
                  time: d.deliveredAt != null ? dateFormat.format(d.deliveredAt!) : 'Delivered',
                  tag: '+50 pts',
                  type: 'deliveries',
                  isDelivered: true,
                )),
            ...liveActive.map((d) => _ActivityItemData(
                  title: 'Food Pickup In Progress: ${d.title}',
                  location: (d.city.isNotEmpty &&
                          !d.pickupAddress.toLowerCase().contains(d.city.toLowerCase()) &&
                          !d.city.toLowerCase().contains('pune'))
                      ? '${d.pickupAddress}, ${d.city}'
                      : d.pickupAddress,
                  time: d.assignedAt != null ? dateFormat.format(d.assignedAt!) : 'In Progress',
                  tag: 'In Progress',
                  type: 'donations',
                  isDelivered: false,
                )),
          ]
        : mockActivities;

    final filtered = displayItems.where((a) {
      if (_selectedTab == 'donations') return a.type == 'donations';
      if (_selectedTab == 'deliveries') return a.type == 'deliveries';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => context.push('/volunteer/profile'),
        ),
        title: const Text(
          'My Activity',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Pill Bar (All, Donations, Deliveries)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                _buildFilterChip('all', 'All'),
                const SizedBox(width: 10),
                _buildFilterChip('donations', 'Donations'),
                const SizedBox(width: 10),
                _buildFilterChip('deliveries', 'Deliveries'),
              ],
            ),
          ),

          // Activity Timeline List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _buildActivityCard(item, isDark);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const VolunteerBottomNav(currentIndex: 3),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedTab == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.charcoal,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(_ActivityItemData item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.isDelivered ? AppColors.primaryGreen.withOpacity(0.12) : const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.isDelivered ? Icons.check_circle_outline : Icons.local_shipping_outlined,
              color: item.isDelivered ? AppColors.primaryGreen : AppColors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.location,
                  style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.time,
                  style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: item.isDelivered ? AppColors.primaryGreen.withOpacity(0.12) : const Color(0xFFEBF5FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.tag,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: item.isDelivered ? AppColors.primaryGreen : const Color(0xFF2980B9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItemData {
  final String title;
  final String location;
  final String time;
  final String tag;
  final String type;
  final bool isDelivered;

  _ActivityItemData({
    required this.title,
    required this.location,
    required this.time,
    required this.tag,
    required this.type,
    required this.isDelivered,
  });
}
