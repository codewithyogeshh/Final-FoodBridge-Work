import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/donation_image_widget.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../../../core/widgets/fb_status_chip.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/presentation/donation_provider.dart';

class NgoClaimsScreen extends StatelessWidget {
  const NgoClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final donationProvider = context.watch<DonationProvider>();
    final ngoId = auth.user?.id ?? 'usr-ngo-202';

    final claimedDonations = donationProvider.getDonationsClaimedByNgo(ngoId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Shelter Claims'),
      ),
      body: claimedDonations.isEmpty
          ? FBEmptyState(
              title: 'No Active Claims',
              description: 'Your shelter has not claimed any donations. Explore nearby listings to reserve surplus for your residents.',
              icon: Icons.volunteer_activism_outlined,
              actionLabel: 'Explore Listings',
              onAction: () => context.go('/ngo'),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: claimedDonations.length,
              itemBuilder: (context, index) {
                final d = claimedDonations[index];
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
                                      'Donor: ${d.donorName} • ${d.city}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FBStatusChip(status: d.status.name),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Must collect by ${DateFormat('hh:mm a').format(d.pickupDeadline)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.orange,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          if (d.assignedVolunteerName != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.warmCream,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.two_wheeler, size: 16, color: AppColors.primaryGreen),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Courier: ${d.assignedVolunteerName} (${d.assignedVolunteerPhone ?? "In Transit"})',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.map_outlined, size: 16),
                                label: const Text('कूरियर थेट ट्रॅकिंग पहा (Live Courier Track)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryGreen,
                                  side: const BorderSide(color: AppColors.primaryGreen),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed: () => context.push('/tracking/${d.id}'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
