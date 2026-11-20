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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getStatusConfig(status);
    final bg = isDark ? config.textColor.withOpacity(0.18) : config.backgroundColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: config.textColor.withOpacity(isDark ? 0.35 : 0.25),
          width: 1,
        ),
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
      case 'assignedforpickup':
      case 'assigned':
        return _StatusConfig(
          label: 'Volunteer Assigned',
          textColor: AppColors.statusAssignedText,
          backgroundColor: AppColors.statusAssignedBg,
          icon: Icons.two_wheeler,
        );
      case 'picked_up':
      case 'pickedup':
      case 'intransit':
      case 'in_transit':
        return _StatusConfig(
          label: 'In Transit',
          textColor: AppColors.statusInTransitText,
          backgroundColor: AppColors.statusInTransitBg,
          icon: Icons.local_shipping_outlined,
        );
      case 'delivered_to_ngo':
      case 'deliveredtongo':
      case 'delivered':
        return _StatusConfig(
          label: 'Delivered / वितरण पूर्ण ✓',
          textColor: AppColors.statusDeliveredText,
          backgroundColor: AppColors.statusDeliveredBg,
          icon: Icons.check_circle,
        );
      case 'distributed':
      case 'distribution_recorded':
        return _StatusConfig(
          label: 'Distributed / वाटप झाले',
          textColor: AppColors.statusCompletedText,
          backgroundColor: AppColors.statusCompletedBg,
          icon: Icons.favorite_border,
        );
      case 'completed':
        return _StatusConfig(
          label: 'Completed / पूर्ण',
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

