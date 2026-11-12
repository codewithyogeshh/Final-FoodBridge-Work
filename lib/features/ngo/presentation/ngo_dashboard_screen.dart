import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _NgoDashboardScreenState();
}

class _NgoDashboardScreenState extends State<NgoDashboardScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Portal'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verified Shelter Header Banner
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.deepGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified, color: AppColors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Annapoorna Welfare Trust',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Verified Charity • 120 Bed Shelter',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('all', 'All Donations'),
                  const SizedBox(width: 8),
                  _filterChip('food', 'Surplus Food 🍛'),
                  const SizedBox(width: 8),
                  _filterChip('clothing', 'Clothing 👕'),
                  const SizedBox(width: 8),
                  _filterChip('urgent', 'Expiring Soon ⏳'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Available Donations Feed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Near You',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '3 listings',
                  style: TextStyle(color: AppColors.mutedGrey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Donation 1
            _DonationFeedCard(
              title: '35 kg Cooked Banquet Meals',
              category: 'Cooked Food',
              donor: 'Royal Feast Banquet',
              location: 'Andheri West (~3.8 km away)',
              quantityText: '35 kg • ~90 Portions',
              status: 'available',
              expiryText: 'Expires in 42 mins',
              isUrgent: true,
              icon: Icons.soup_kitchen,
              onClaim: () => _handleClaim(context, '35 kg Cooked Meals'),
            ),
            const SizedBox(height: 12),

            // Donation 2
            _DonationFeedCard(
              title: '25 Pairs of Clean Winter Sweaters',
              category: 'Clothing',
              donor: 'Priya Kulkarni',
              location: 'Bandra West (~6.2 km away)',
              quantityText: '25 Pieces • Like New',
              status: 'available',
              expiryText: 'Pickup next 48 hrs',
              isUrgent: false,
              icon: Icons.checkroom,
              onClaim: () => _handleClaim(context, '25 Winter Sweaters'),
            ),
            const SizedBox(height: 12),

            // Donation 3
            _DonationFeedCard(
              title: '15 kg Bakery Breads & Buns',
              category: 'Bakery',
              donor: 'City Oven Bakery',
              location: 'Santa Cruz (~4.5 km away)',
              quantityText: '15 kg • Fresh Pack',
              status: 'available',
              expiryText: 'Expires in 3 hrs',
              isUrgent: false,
              icon: Icons.bakery_dining,
              onClaim: () => _handleClaim(context, '15 kg Bakery Breads'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen.withOpacity(0.18),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepGreen : AppColors.mutedGrey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = key);
      },
    );
  }

  void _handleClaim(BuildContext context, String itemTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Claim $itemTitle',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepGreen),
              ),
              const SizedBox(height: 8),
              const Text(
                'Atomic reservation will lock this quantity for your shelter.',
                style: TextStyle(color: AppColors.mutedGrey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              FBButton(
                label: 'Confirm Claim (Self-Collection)',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reservation confirmed! Proceed to self-collection.'),
                      backgroundColor: AppColors.deepGreen,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              FBButton(
                label: 'Request Volunteer Delivery Courier',
                variant: FBButtonVariant.secondary,
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Volunteer dispatch task created and broadcasted!'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DonationFeedCard extends StatelessWidget {
  final String title;
  final String category;
  final String donor;
  final String location;
  final String quantityText;
  final String status;
  final String expiryText;
  final bool isUrgent;
  final IconData icon;
  final VoidCallback onClaim;

  const _DonationFeedCard({
    required this.title,
    required this.category,
    required this.donor,
    required this.location,
    required this.quantityText,
    required this.status,
    required this.expiryText,
    required this.isUrgent,
    required this.icon,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 2),
                      Text('$donor • $location', style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warmCream,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(quantityText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepGreen)),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: isUrgent ? AppColors.errorRed : AppColors.orange),
                      const SizedBox(width: 4),
                      Text(
                        expiryText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isUrgent ? AppColors.errorRed : AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FBButton(
              label: 'Claim Donation',
              height: 44,
              onPressed: onClaim,
            ),
          ],
        ),
      ),
    );
  }
}
