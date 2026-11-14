import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';
import 'widgets/volunteer_bottom_nav.dart';

/// Screen 3: Volunteer Available Tasks
/// Real-time multi-role connected task list matching reference mockup
class VolunteerAvailableTasksScreen extends StatefulWidget {
  const VolunteerAvailableTasksScreen({super.key});

  @override
  State<VolunteerAvailableTasksScreen> createState() => _VolunteerAvailableTasksScreenState();
}

class _VolunteerAvailableTasksScreenState extends State<VolunteerAvailableTasksScreen> {
  String _selectedFilter = 'all'; // 'all', 'pickup', 'delivery'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final donationProvider = context.watch<DonationProvider>();
    final auth = context.watch<AuthProvider>();
    final volunteerId = auth.user?.id ?? 'usr-vol-301';

    // Real-time available tasks from DonationProvider
    final liveTasks = donationProvider.volunteerAvailableTasks;

    // Fallback tasks if live stream is empty
    final mockFallbackTasks = [
      _TaskCardData(
        id: 'don-mock-01',
        title: 'Food Pickup',
        location: 'Hotel Grand Plaza',
        time: 'Today • 6:00 PM',
        distance: '2.4 km',
        isPickup: true,
        isFood: true,
      ),
      _TaskCardData(
        id: 'don-mock-02',
        title: 'Delivery Task',
        location: 'Slum Area, Pune',
        time: 'Today • 7:30 PM',
        distance: '3.1 km',
        isPickup: false,
        isFood: true,
      ),
      _TaskCardData(
        id: 'don-mock-03',
        title: 'Food Pickup',
        location: 'Cafe Delight',
        time: 'Tomorrow • 10:00 AM',
        distance: '4.8 km',
        isPickup: true,
        isFood: true,
      ),
      _TaskCardData(
        id: 'don-mock-04',
        title: 'Delivery Task',
        location: 'Kothrud Area',
        time: 'Tomorrow • 11:00 AM',
        distance: '5.2 km',
        isPickup: false,
        isFood: false,
      ),
    ];

    final hasLive = liveTasks.isNotEmpty;
    final dateFormat = DateFormat('hh:mm a');

    final displayItems = hasLive
        ? liveTasks.map((d) {
            return _TaskCardData(
              id: d.id,
              title: d.isFood ? 'Food Pickup' : 'Clothing Pickup',
              location: '${d.pickupAddress} (${d.city})',
              time: 'Deadline: ${dateFormat.format(d.pickupDeadline)}',
              distance: '~${d.estimatedDistanceKm.toStringAsFixed(1)} km',
              isPickup: true,
              isFood: d.isFood,
              originalDonation: d,
            );
          }).toList()
        : mockFallbackTasks;

    // Filter items
    final filtered = displayItems.where((t) {
      if (_selectedFilter == 'pickup') return t.isPickup;
      if (_selectedFilter == 'delivery') return !t.isPickup;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/volunteer'),
        ),
        title: const Text(
          'Available Tasks',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Pill Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                _buildFilterChip('all', 'All (12)'),
                const SizedBox(width: 10),
                _buildFilterChip('pickup', 'Pickup (6)'),
                const SizedBox(width: 10),
                _buildFilterChip('delivery', 'Delivery (6)'),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _buildTaskCard(
                  item: item,
                  isDark: isDark,
                  onAccept: () async {
                    if (item.originalDonation != null) {
                      await donationProvider.acceptVolunteerTask(
                        donationId: item.id,
                        volunteerId: volunteerId,
                        volunteerName: auth.user?.fullName ?? 'Volunteer',
                        phone: auth.user?.phone ?? '',
                      );
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Task accepted: ${item.title}!'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                      context.push('/volunteer/tracking');
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const VolunteerBottomNav(currentIndex: 1),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.25),
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

  Widget _buildTaskCard({
    required _TaskCardData item,
    required bool isDark,
    required VoidCallback onAccept,
  }) {
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.isFood
                  ? const Color(0xFFF39C12).withOpacity(0.12)
                  : AppColors.primaryGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.isFood ? Icons.ramen_dining : Icons.checkroom,
              color: item.isFood ? const Color(0xFFE67E22) : AppColors.primaryGreen,
              size: 26,
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: AppColors.mutedGrey),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        item.location,
                        style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 13, color: AppColors.mutedGrey),
                    const SizedBox(width: 3),
                    Text(
                      item.time,
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.distance,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            height: 36,
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(70, 34),
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                elevation: 0,
              ),
              child: const Text(
                'Accept',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCardData {
  final String id;
  final String title;
  final String location;
  final String time;
  final String distance;
  final bool isPickup;
  final bool isFood;
  final Donation? originalDonation;

  _TaskCardData({
    required this.id,
    required this.title,
    required this.location,
    required this.time,
    required this.distance,
    required this.isPickup,
    required this.isFood,
    this.originalDonation,
  });
}
