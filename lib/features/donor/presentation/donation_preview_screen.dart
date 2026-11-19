import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/donation_image_widget.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_card.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';

class DonationPreviewScreen extends StatefulWidget {
  final Donation donation;

  const DonationPreviewScreen({
    super.key,
    required this.donation,
  });

  @override
  State<DonationPreviewScreen> createState() => _DonationPreviewScreenState();
}

class _DonationPreviewScreenState extends State<DonationPreviewScreen> {
  bool _isPublishing = false;
  bool _isSavingDraft = false;

  Future<void> _publishDonation() async {
    setState(() => _isPublishing = true);
    final provider = context.read<DonationProvider>();

    final toPublish = widget.donation.copyWith(
      status: DonationStatus.available,
    );

    final success = await provider.createDonation(toPublish);
    if (!mounted) return;
    setState(() => _isPublishing = false);

    if (success) {
      _showSuccessDialog(
        title: 'Donation Published!',
        message:
            'Your listing is now live! Verified NGOs in your area have been notified. Once an NGO accepts your donation, a volunteer will be dispatched for pickup.',
        isDraft: false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to publish donation.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _saveDraft() async {
    setState(() => _isSavingDraft = true);
    final provider = context.read<DonationProvider>();

    final draft = widget.donation.copyWith(
      status: DonationStatus.draft,
    );

    final success = await provider.createDonation(draft);
    if (!mounted) return;
    setState(() => _isSavingDraft = false);

    if (success) {
      _showSuccessDialog(
        title: 'Draft Saved',
        message:
            'Your donation has been saved as a draft. You can review, edit, or publish it anytime from "My Donations".',
        isDraft: true,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save draft.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _showSuccessDialog({
    required String title,
    required String message,
    required bool isDraft,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsOverflowButtonSpacing: 8,
        title: Row(
          children: [
            Icon(
              isDraft ? Icons.save_outlined : Icons.check_circle,
              color: isDraft ? AppColors.orange : AppColors.primaryGreen,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/donor/dashboard');
            },
            child: const Text('Go to Dashboard'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/donor/my-donations');
            },
            child: const Text('View My Donations'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.donation;
    final dateFormat = DateFormat('EEE, d MMM yyyy - hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Listing Preview'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Preview Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.orange.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.remove_red_eye, color: AppColors.orange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This is how verified NGOs will see your donation before claiming.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.charcoal,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main Listing Card Preview
            FBCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo with badges
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: DonationImageWidget(
                          imageUrl: d.imageUrl,
                          isFood: d.isFood,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          enableFullScreenOnTap: true,
                          title: d.title,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                d.isFood ? Icons.restaurant_menu : Icons.checkroom,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                d.isFood ? 'FOOD SURPLUS' : 'CLOTHING DONATION',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (d.isFood)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: d.isVeg ? Colors.green[700] : Colors.red[700],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              d.isVeg ? 'PURE VEG' : 'NON-VEG',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Content details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          d.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.charcoal.withOpacity(0.85),
                                height: 1.4,
                              ),
                        ),
                        const Divider(height: 24),

                        // Specs Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                context,
                                icon: Icons.scale,
                                title: 'Quantity',
                                value: '${d.quantity.toStringAsFixed(0)} ${d.unit}',
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                context,
                                icon: Icons.hourglass_top,
                                title: 'Deadline',
                                value: dateFormat.format(d.pickupDeadline),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (d.isFood) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  context,
                                  icon: Icons.ac_unit,
                                  title: 'Storage Required',
                                  value: (d.storageCondition ?? 'Ambient').toUpperCase(),
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  context,
                                  icon: Icons.verified_user_outlined,
                                  title: 'FSSAI Hygiene',
                                  value: 'Pledged & Certified',
                                ),
                              ),
                            ],
                          ),
                          if (d.allergenNotes != null && d.allergenNotes!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Allergens: ${d.allergenNotes}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.charcoal,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  context,
                                  icon: Icons.category,
                                  title: 'Category',
                                  value: d.clothingCategory ?? 'Clothing',
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  context,
                                  icon: Icons.accessibility_new,
                                  title: 'Target Size',
                                  value: d.targetSize ?? 'Free Size',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  context,
                                  icon: Icons.thumb_up_alt_outlined,
                                  title: 'Condition',
                                  value: d.conditionGrade ?? 'Like New',
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  context,
                                  icon: Icons.local_laundry_service,
                                  title: 'Hygiene Cleaned',
                                  value: 'Freshly Laundered',
                                ),
                              ),
                            ],
                          ),
                        ],

                        const Divider(height: 24),

                        // Pickup Address preview with privacy mask notice
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup Location',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    d.pickupAddress,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.charcoal),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Public NGO discovery displays approximate locality (${d.city}). Exact address unlocks only when a volunteer is dispatched.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.mutedGrey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            FBButton(
              label: 'Publish Donation Now',
              icon: Icons.send_rounded,
              isLoading: _isPublishing,
              onPressed: _publishDonation,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.charcoal,
                side: const BorderSide(color: AppColors.mutedGrey),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSavingDraft ? null : _saveDraft,
              icon: _isSavingDraft
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bookmark_border),
              label: const Text(
                'Save as Draft',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryGreen),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedGrey),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
