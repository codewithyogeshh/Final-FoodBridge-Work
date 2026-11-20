import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/donation.dart';
import '../donation_provider.dart';

class DonationStatusTimeline extends StatelessWidget {
  final Donation donation;

  const DonationStatusTimeline({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM • hh:mm a');
    String resolvedVolName = donation.assignedVolunteerName ?? '';
    try {
      final dp = context.watch<DonationProvider>();
      resolvedVolName = dp.resolveVolunteerName(
        donation.assignedVolunteerId,
        donation.assignedVolunteerName,
      );
    } catch (_) {}

    final isClaimed =
        donation.status == DonationStatus.accepted ||
        donation.status == DonationStatus.assignedForPickup ||
        donation.status == DonationStatus.pickedUp ||
        donation.status == DonationStatus.deliveredToNgo ||
        donation.status == DonationStatus.distributed ||
        donation.status == DonationStatus.completed ||
        (donation.claimedByNgoName != null &&
            donation.claimedByNgoName!.isNotEmpty);

    final isAssigned =
        donation.status == DonationStatus.assignedForPickup ||
        donation.status == DonationStatus.pickedUp ||
        donation.status == DonationStatus.deliveredToNgo ||
        donation.status == DonationStatus.distributed ||
        donation.status == DonationStatus.completed ||
        (donation.assignedVolunteerName != null &&
            donation.assignedVolunteerName!.isNotEmpty);

    final isPickedUp =
        donation.status == DonationStatus.pickedUp ||
        donation.status == DonationStatus.deliveredToNgo ||
        donation.status == DonationStatus.distributed ||
        donation.status == DonationStatus.completed ||
        donation.pickedUpAt != null;

    final isDelivered =
        donation.status == DonationStatus.deliveredToNgo ||
        donation.status == DonationStatus.distributed ||
        donation.status == DonationStatus.completed ||
        donation.deliveredAt != null;

    final steps = [
      _TimelineStep(
        title: 'Listed on FoodBridge',
        subtitle: 'Available for verified NGO shelters',
        timestamp: dateFormat.format(donation.createdAt),
        isDone: true,
        isActive: !isClaimed,
      ),
      _TimelineStep(
        title:
            donation.claimedByNgoName != null &&
                donation.claimedByNgoName!.isNotEmpty
            ? 'Claimed by ${donation.claimedByNgoName}'
            : 'NGO Shelter Claim',
        subtitle:
            donation.claimedByNgoName != null &&
                donation.claimedByNgoName!.isNotEmpty
            ? 'Shelter committed to receiving cargo'
            : 'Pending shelter request',
        timestamp: donation.claimedAt != null
            ? dateFormat.format(donation.claimedAt!)
            : (isClaimed
                  ? dateFormat.format(
                      donation.createdAt.add(const Duration(minutes: 5)),
                    )
                  : null),
        isDone: isClaimed,
        isActive: isClaimed && !isAssigned,
      ),
      _TimelineStep(
        title:
            resolvedVolName.isNotEmpty
            ? 'Courier: $resolvedVolName'
            : 'Volunteer Dispatch',
        subtitle:
            resolvedVolName.isNotEmpty
            ? 'Volunteer accepted transport mission'
            : 'Awaiting rider acceptance',
        timestamp: donation.assignedAt != null
            ? dateFormat.format(donation.assignedAt!)
            : (isAssigned
                  ? dateFormat.format(
                      donation.createdAt.add(const Duration(minutes: 10)),
                    )
                  : null),
        isDone: isAssigned,
        isActive: isAssigned && !isPickedUp,
      ),
      _TimelineStep(
        title: 'Picked Up (In Transit)',
        subtitle: 'Food verified and packed on vehicle',
        timestamp: donation.pickedUpAt != null
            ? dateFormat.format(donation.pickedUpAt!)
            : null,
        isDone: isPickedUp,
        isActive: isPickedUp && !isDelivered,
      ),
      _TimelineStep(
        title: 'Safe Handover & Delivered',
        subtitle: 'Received and verified at shelter',
        timestamp: donation.deliveredAt != null
            ? dateFormat.format(donation.deliveredAt!)
            : null,
        isDone: isDelivered,
        isActive: isDelivered,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chain of Custody Timeline',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return _buildTimelineItem(context, step, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    _TimelineStep step,
    bool isLast,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color dotColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    if (step.isDone) dotColor = AppColors.primaryGreen;
    if (step.isActive) dotColor = AppColors.warningOrange;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: dotColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: Center(
                  child: step.isDone
                      ? Icon(Icons.check, size: 12, color: dotColor)
                      : Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.isDone
                        ? AppColors.primaryGreen
                        : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: TextStyle(
                            fontWeight: step.isDone || step.isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 13,
                            color: step.isDone || step.isActive
                                ? (isDark
                                      ? AppColors.textDarkPrimary
                                      : AppColors.charcoal)
                                : AppColors.mutedGrey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (step.timestamp != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          step.timestamp!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.mutedGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final String? timestamp;
  final bool isDone;
  final bool isActive;

  _TimelineStep({
    required this.title,
    required this.subtitle,
    this.timestamp,
    required this.isDone,
    required this.isActive,
  });
}
