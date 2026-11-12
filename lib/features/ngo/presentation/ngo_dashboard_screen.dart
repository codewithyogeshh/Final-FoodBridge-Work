import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../../authentication/domain/models/app_user.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _NgoDashboardScreenState();
}

class _NgoDashboardScreenState extends State<NgoDashboardScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final donationProvider = context.watch<DonationProvider>();
    final currentUser = auth.user;

    // Filter available donations
    final allAvailable = donationProvider.availableDonations;
    final filteredAvailable = allAvailable.where((d) {
      if (_selectedFilter == 'food') return d.isFood;
      if (_selectedFilter == 'clothing') return d.isClothing;
      if (_selectedFilter == 'urgent') return d.isUrgent;
      return true;
    }).toList();

    // Claimed by this NGO
    final claimedByMe = donationProvider.getDonationsClaimedByNgo(
      currentUser?.id ?? 'usr-ngo-202',
    );

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
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.push('/ngo/verification'),
              child: Container(
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
                      child: const Icon(
                        Icons.verified,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.organizationName ??
                                'Asha Children Foundation',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Darpan: ${currentUser?.darpanId ?? "MH/2019/0219482"} • Tap to view verification',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Portal Actions
            Row(
              children: [
                Expanded(
                  child: _PortalQuickCard(
                    icon: Icons.assignment_outlined,
                    label: 'Claims',
                    badge: '${claimedByMe.length}',
                    color: AppColors.primaryGreen,
                    onTap: () => context.push('/ngo/my-claims'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PortalQuickCard(
                    icon: Icons.handshake_outlined,
                    label: 'Distributions',
                    badge: '${donationProvider.getNgoDistributionRecords(currentUser?.id ?? "usr-ngo-202").length}',
                    color: AppColors.orange,
                    onTap: () => context.push('/ngo/distribution-records'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PortalQuickCard(
                    icon: Icons.verified_user_outlined,
                    label: 'Verification',
                    badge: currentUser?.ngoVerificationStatus == NgoVerificationStatus.verified ? 'Active' : 'Pending',
                    color: AppColors.deepGreen,
                    onTap: () => context.push('/ngo/verification'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('all', 'All Donations (${allAvailable.length})'),
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
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${filteredAvailable.length} listings',
                  style: const TextStyle(
                    color: AppColors.mutedGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (filteredAvailable.isEmpty)
              const FBEmptyState(
                title: 'No Donations Matching Filter',
                description: 'Check back soon or select "All Donations" to see new listings.',
                icon: Icons.search_off_rounded,
              )
            else
              ...filteredAvailable.map((d) {
                final dateFormat = DateFormat('hh:mm a');
                return _DonationFeedCard(
                  donation: d,
                  title: d.title,
                  category: d.isFood ? 'Cooked Food' : 'Clothing',
                  donor: d.donorName,
                  location: '${d.city} (Locality masked) • ~${d.estimatedDistanceKm.toStringAsFixed(1)} km',
                  quantityText: '${d.quantity.toStringAsFixed(0)} ${d.unit}',
                  expiryText:
                      'Deadline: ${dateFormat.format(d.pickupDeadline)}',
                  isUrgent: d.isUrgent,
                  icon: d.isFood ? Icons.soup_kitchen : Icons.checkroom,
                  onTap: () => context.push('/donation-detail/${d.id}'),
                  onClaim: () => _handleClaim(
                    context,
                    d,
                    donationProvider,
                    currentUser,
                  ),
                );
              }),

            const SizedBox(height: 28),

            // Shelter Active Claims
            if (claimedByMe.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Our Active Claims (${claimedByMe.length})',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.push('/ngo/my-claims'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...claimedByMe.map((d) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
                      child: Icon(
                        d.isFood ? Icons.restaurant : Icons.checkroom,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      d.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      d.assignedVolunteerName != null
                          ? 'Volunteer: ${d.assignedVolunteerName} (${d.status.displayName})'
                          : 'Status: Awaiting Volunteer Pickup',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedGrey,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.mutedGrey,
                    ),
                    onTap: () => context.push('/donation-detail/${d.id}'),
                  ),
                );
              }),
            ],
            const SizedBox(height: 40),
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

  void _handleClaim(
    BuildContext context,
    Donation donation,
    DonationProvider donationProvider,
    AppUser? currentUser,
  ) {
    final ngoId = currentUser?.id ?? 'usr-ngo-202';
    final ngoName = currentUser?.organizationName ?? 'Asha Children Foundation';
    final isVerified = currentUser == null ||
        currentUser.ngoVerificationStatus == NgoVerificationStatus.verified ||
        currentUser.role != UserRole.ngo;

    if (!isVerified) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: AppColors.orange, size: 26),
              SizedBox(width: 8),
              Text('Verification Required'),
            ],
          ),
          content: const Text(
            'Your NGO registration is currently pending administrative verification. Only verified NGOs with active 80G and Darpan credentials can claim donations to ensure food safety and community integrity.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.push('/ngo/verification');
              },
              child: const Text('View Verification'),
            ),
          ],
        ),
      );
      return;
    }

    final qtyController = TextEditingController(text: donation.quantity.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Claim ${donation.title}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Available: ${donation.quantity.toStringAsFixed(0)} ${donation.unit} • Must collect before ${DateFormat('hh:mm a').format(donation.pickupDeadline)}',
                style: const TextStyle(
                  color: AppColors.mutedGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              FBTextField(
                label: 'Quantity to Claim (${donation.unit})',
                controller: qtyController,
                hint: 'e.g. ${donation.quantity.toStringAsFixed(0)}',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              FBButton(
                label: 'Confirm Claim (Broadcast for Volunteer)',
                onPressed: () async {
                  final requestedQty = double.tryParse(qtyController.text.trim()) ?? donation.quantity;
                  Navigator.pop(bottomSheetContext);
                  final success = await donationProvider.claimDonation(
                    donationId: donation.id,
                    ngoId: ngoId,
                    ngoName: ngoName,
                    requestedQuantity: requestedQty,
                    isVerifiedNgo: isVerified,
                  );
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Donation claimed! Broadcasted to volunteers for pickup.',
                          ),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(donationProvider.errorMessage ?? 'Claim failed.'),
                          backgroundColor: AppColors.errorRed,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 10),
              FBButton(
                label: 'Cancel',
                variant: FBButtonVariant.secondary,
                onPressed: () => Navigator.pop(bottomSheetContext),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DonationFeedCard extends StatelessWidget {
  final Donation donation;
  final String title;
  final String category;
  final String donor;
  final String location;
  final String quantityText;
  final String expiryText;
  final bool isUrgent;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onClaim;

  const _DonationFeedCard({
    required this.donation,
    required this.title,
    required this.category,
    required this.donor,
    required this.location,
    required this.quantityText,
    required this.expiryText,
    required this.isUrgent,
    required this.icon,
    required this.onTap,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$donor • $location',
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warmCream,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      quantityText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepGreen,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: isUrgent
                              ? AppColors.errorRed
                              : AppColors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          expiryText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isUrgent
                                ? AppColors.errorRed
                                : AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FBButton(label: 'Claim Donation', height: 44, onPressed: onClaim),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortalQuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String badge;
  final Color color;
  final VoidCallback onTap;

  const _PortalQuickCard({
    required this.icon,
    required this.label,
    required this.badge,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              badge,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
