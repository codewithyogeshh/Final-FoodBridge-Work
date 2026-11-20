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
import 'widgets/ngo_handover_qr_modal.dart';

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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Donor: ${d.donorName} • ${d.city}',
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
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FBStatusChip(
                                    status: (d.isDelivered || d.deliveredAt != null)
                                        ? 'delivered_to_ngo'
                                        : (d.isExpired
                                            ? 'expired'
                                            : (d.isInTransit
                                                ? 'in_transit'
                                                : (d.isAssigned
                                                    ? 'assigned_for_pickup'
                                                    : 'accepted'))),
                                  ),
                                  if (!d.isDelivered && d.deliveredAt == null && !d.isExpired) ...[
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => showNgoHandoverQrModal(context, d),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.qr_code_2, size: 13, color: AppColors.primaryGreen),
                                            const SizedBox(width: 4),
                                            Text(
                                              'OTP: ${d.deliveryOtp}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  (d.isDelivered || d.deliveredAt != null)
                                      ? 'वितरण पूर्ण (${d.deliveredAt != null ? DateFormat('hh:mm a').format(d.deliveredAt!) : "Delivered"})'
                                      : (d.isExpired
                                          ? 'कालबाह्य झाले (Expired)'
                                          : 'Must collect by ${DateFormat('hh:mm a').format(d.pickupDeadline)}'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: d.isExpired
                                        ? AppColors.errorRed
                                        : ((d.isDelivered || d.deliveredAt != null)
                                            ? AppColors.primaryGreen
                                            : AppColors.orange),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          if (d.assignedVolunteerName != null || d.assignedVolunteerId != null) ...[
                            Builder(builder: (context) {
                              final volName = donationProvider.resolveVolunteerName(
                                d.assignedVolunteerId,
                                d.assignedVolunteerName,
                              );
                              return Column(
                                children: [
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
                                            'Courier: $volName (${d.assignedVolunteerPhone ?? "In Transit"})',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                              );
                            }),
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
