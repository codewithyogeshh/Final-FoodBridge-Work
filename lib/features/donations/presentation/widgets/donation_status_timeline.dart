import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/donation.dart';

class DonationStatusTimeline extends StatelessWidget {
  final Donation donation;

  const DonationStatusTimeline({
    super.key,
    required this.donation,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM • hh:mm a');

    final steps = [
      _TimelineStep(
        title: 'Listed on FoodBridge',
        subtitle: 'Available for verified NGO shelters',
        timestamp: dateFormat.format(donation.createdAt),
        isDone: true,
        isActive: donation.status == DonationStatus.listed,
      ),
      _TimelineStep(
        title: donation.claimedByNgoName != null
            ? 'Claimed by ${donation.claimedByNgoName}'
            : 'NGO Shelter Claim',
        subtitle: donation.claimedByNgoName != null
            ? 'Shelter committed to receiving cargo'
            : 'Pending shelter request',
        timestamp: donation.claimedAt != null
            ? dateFormat.format(donation.claimedAt!)
            : null,
        isDone: donation.status != DonationStatus.listed &&
            donation.status != DonationStatus.cancelled &&
            donation.status != DonationStatus.expired,
        isActive: donation.status == DonationStatus.claimed,
      ),
      _TimelineStep(
        title: donation.assignedVolunteerName != null
            ? 'Courier: ${donation.assignedVolunteerName}'
            : 'Volunteer Dispatch',
        subtitle: donation.assignedVolunteerName != null
            ? 'Volunteer accepted transport mission'
            : 'Awaiting rider acceptance',
        timestamp: donation.assignedAt != null
            ? dateFormat.format(donation.assignedAt!)
            : null,
        isDone: donation.status == DonationStatus.assigned ||
            donation.status == DonationStatus.pickedUp ||
            donation.status == DonationStatus.delivered,
        isActive: donation.status == DonationStatus.assigned,
      ),
      _TimelineStep(
        title: 'Picked Up (In Transit)',
        subtitle: 'Food verified and packed on vehicle',
        timestamp: donation.pickedUpAt != null
            ? dateFormat.format(donation.pickedUpAt!)
            : null,
        isDone: donation.status == DonationStatus.pickedUp ||
            donation.status == DonationStatus.delivered,
        isActive: donation.status == DonationStatus.pickedUp,
      ),
      _TimelineStep(
        title: 'Safe Handover & Delivered',
        subtitle: 'Received and verified at shelter',
        timestamp: donation.deliveredAt != null
            ? dateFormat.format(donation.deliveredAt!)
            : null,
        isDone: donation.status == DonationStatus.delivered,
        isActive: donation.status == DonationStatus.delivered,
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
            return _buildTimelineItem(step, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(_TimelineStep step, bool isLast) {
    Color dotColor = AppColors.borderLight;
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
                        : AppColors.borderLight,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontWeight:
                              step.isDone || step.isActive ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                          color: step.isDone || step.isActive
                              ? AppColors.charcoal
                              : AppColors.mutedGrey,
                        ),
                      ),
                      if (step.timestamp != null)
                        Text(
                          step.timestamp!,
                          style: const TextStyle(fontSize: 10, color: AppColors.mutedGrey),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey),
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

