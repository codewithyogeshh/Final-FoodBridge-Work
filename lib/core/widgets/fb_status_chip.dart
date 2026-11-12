import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FBStatusChip extends StatelessWidget {
  final String status;
  final bool compact;

  const FBStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: config.textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: compact ? 12 : 14,
            color: config.textColor,
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return _StatusConfig(
          label: 'Available',
          textColor: AppColors.statusAvailableText,
          backgroundColor: AppColors.statusAvailableBg,
          icon: Icons.check_circle_outline,
        );
      case 'requested':
        return _StatusConfig(
          label: 'Request Received',
          textColor: AppColors.statusRequestedText,
          backgroundColor: AppColors.statusRequestedBg,
          icon: Icons.front_hand_outlined,
        );
      case 'accepted':
        return _StatusConfig(
          label: 'Accepted',
          textColor: AppColors.statusAcceptedText,
          backgroundColor: AppColors.statusAcceptedBg,
          icon: Icons.verified_outlined,
        );
      case 'assigned_for_pickup':
        return _StatusConfig(
          label: 'Volunteer Assigned',
          textColor: AppColors.statusAssignedText,
          backgroundColor: AppColors.statusAssignedBg,
          icon: Icons.two_wheeler,
        );
      case 'picked_up':
        return _StatusConfig(
          label: 'In Transit',
          textColor: AppColors.statusInTransitText,
          backgroundColor: AppColors.statusInTransitBg,
          icon: Icons.local_shipping_outlined,
        );
      case 'delivered_to_ngo':
        return _StatusConfig(
          label: 'Delivered to NGO',
          textColor: AppColors.statusDeliveredText,
          backgroundColor: AppColors.statusDeliveredBg,
          icon: Icons.location_city_outlined,
        );
      case 'distributed':
        return _StatusConfig(
          label: 'Distribution Recorded',
          textColor: AppColors.statusCompletedText,
          backgroundColor: AppColors.statusCompletedBg,
          icon: Icons.favorite_border,
        );
      case 'completed':
        return _StatusConfig(
          label: 'Completed',
          textColor: AppColors.statusCompletedText,
          backgroundColor: AppColors.statusCompletedBg,
          icon: Icons.done_all,
        );
      case 'cancelled':
        return _StatusConfig(
          label: 'Cancelled',
          textColor: AppColors.statusCancelledText,
          backgroundColor: AppColors.statusCancelledBg,
          icon: Icons.block,
        );
      case 'expired':
        return _StatusConfig(
          label: 'Expired',
          textColor: AppColors.statusExpiredText,
          backgroundColor: AppColors.statusExpiredBg,
          icon: Icons.timer_off_outlined,
        );
      case 'rejected':
        return _StatusConfig(
          label: 'Inspection Refusal',
          textColor: AppColors.statusRejectedText,
          backgroundColor: AppColors.statusRejectedBg,
          icon: Icons.report_problem_outlined,
        );
      case 'draft':
      default:
        return _StatusConfig(
          label: 'Draft',
          textColor: AppColors.statusDraftText,
          backgroundColor: AppColors.statusDraftBg,
          icon: Icons.edit_note_outlined,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.icon,
  });
}

