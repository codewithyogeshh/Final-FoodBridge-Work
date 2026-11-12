import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';
import '../../donations/presentation/widgets/donation_status_timeline.dart';

class VolunteerMissionScreen extends StatefulWidget {
  final String donationId;

  const VolunteerMissionScreen({
    super.key,
    required this.donationId,
  });

  @override
  State<VolunteerMissionScreen> createState() => _VolunteerMissionScreenState();
}

class _VolunteerMissionScreenState extends State<VolunteerMissionScreen> {
  final _otpController = TextEditingController();
  bool _packagingIntact = false;
  bool _temperatureChecked = false;
  bool _proofOfHandoverChecked = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmPickup(Donation donation, DonationProvider provider) async {
    if (donation.isFood && (!_packagingIntact || !_temperatureChecked)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify the food safety checklist before confirming physical pickup.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final enteredCode = await _showOtpDialog(
      title: 'Enter Donor Pickup Code',
      description: 'Ask the donor (${donation.donorName}) for their 4-digit FoodBridge verification code to confirm handover.',
      expectedCodeDemo: donation.pickupOtp,
    );

    if (enteredCode != null && mounted) {
      setState(() => _isProcessing = true);
      final success = await provider.confirmPickupWithOtp(
        donationId: donation.id,
        enteredOtp: enteredCode,
      );
      if (mounted) {
        setState(() => _isProcessing = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pickup verified! Route updated: Proceed to NGO Shelter.'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Invalid verification code.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleConfirmDelivery(Donation donation, DonationProvider provider) async {
    final enteredCode = await _showOtpDialog(
      title: 'Enter NGO Handover Code',
      description: 'Ask the shelter manager (${donation.claimedByNgoName ?? "Shelter"}) for their 4-digit receipt confirmation code.',
      expectedCodeDemo: donation.deliveryOtp,
    );

    if (enteredCode != null && mounted) {
      setState(() => _isProcessing = true);
      final success = await provider.confirmDeliveryWithOtp(
        donationId: donation.id,
        enteredOtp: enteredCode,
      );
      if (mounted) {
        setState(() => _isProcessing = false);
        if (success) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Mission Accomplished! 🎉'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: AppColors.primaryGreen, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    'You successfully redistributed ${donation.quantity.toStringAsFixed(0)} ${donation.unit} of surplus to ${donation.claimedByNgoName ?? "the shelter"}.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/volunteer');
                  },
                  child: const Text('Return to Dispatch Dashboard'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Invalid receipt code.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<String?> _showOtpDialog({
    required String title,
    required String description,
    required String expectedCodeDemo,
  }) async {
    final controller = TextEditingController();
    String? localError;

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description, style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Demo Hint Code: $expectedCodeDemo',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepGreen),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '••••',
                      errorText: localError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (controller.text.trim().length != 4) {
                      setDialogState(() => localError = 'Enter 4-digit code');
                      return;
                    }
                    Navigator.pop(ctx, controller.text.trim());
                  },
                  child: const Text('Verify Code'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleReleaseTask(Donation donation, DonationProvider provider) async {
    String selectedCategory = 'Vehicle Breakdown / Flat Tire';
    final notesController = TextEditingController();

    final List<String> issueCategories = [
      'Vehicle Breakdown / Flat Tire',
      'Donor Unavailable / No Response',
      'Incorrect / Inaccessible Address',
      'Cargo Packaging Damaged / Leaking',
      'Severe Weather / Road Blockage',
      'Personal Emergency',
    ];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.report_problem_outlined, color: AppColors.errorRed),
              SizedBox(width: 8),
              Text('Report Issue / Release'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select the issue you encountered. Releasing will immediately reassign this mission to another available courier in the area.',
                  style: TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Issue Category',
                    border: OutlineInputBorder(),
                  ),
                  items: issueCategories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes (Optional)',
                    hintText: 'e.g. Near Swargate bus depot, flat tire.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep Task'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Release Task to Pool'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true && mounted) {
      final finalReason = notesController.text.trim().isNotEmpty
          ? '$selectedCategory - ${notesController.text.trim()}'
          : selectedCategory;
      await provider.cancelVolunteerTask(
        donationId: donation.id,
        reason: finalReason,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task released: $selectedCategory. Broadcasted back to nearby couriers.'),
            backgroundColor: AppColors.charcoal,
          ),
        );
        context.go('/volunteer');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final donationProvider = context.watch<DonationProvider>();
    final donation = donationProvider.getDonationById(widget.donationId);

    if (donation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dispatch Mission')),
        body: const Center(child: Text('Mission not found or completed.')),
      );
    }

    final isPickedUp = donation.status == DonationStatus.pickedUp;
    final dateFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(isPickedUp ? 'In Transit to Shelter' : 'Proceed to Pickup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency_outlined, color: AppColors.errorRed),
            tooltip: 'Release Mission / Emergency',
            onPressed: () => _handleReleaseTask(donation, donationProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mission Status Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isPickedUp ? AppColors.statusInTransitBg : AppColors.warmCream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isPickedUp ? AppColors.primaryGreen : AppColors.warningOrange,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPickedUp ? Icons.two_wheeler : Icons.directions_run,
                      color: isPickedUp ? AppColors.deepGreen : AppColors.warningOrange,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPickedUp ? 'PHASE 2: DELIVER TO SHELTER' : 'PHASE 1: PROCEED TO DONOR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isPickedUp ? AppColors.deepGreen : AppColors.warningOrange,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPickedUp
                                ? 'Cargo in transit. Deliver before ${dateFormat.format(donation.pickupDeadline)}'
                                : 'Collect ${donation.quantity.toStringAsFixed(0)} ${donation.unit} from donor',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Route & Navigation Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Route & Turn-by-Turn GPS',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${donation.estimatedDistanceKm} km • ~${donation.estimatedMinutes} mins',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepGreen),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Visual Waypoints
                    _buildWaypointRow(
                      icon: Icons.trip_origin,
                      iconColor: isPickedUp ? AppColors.mutedGrey : AppColors.primaryGreen,
                      title: 'Pickup: ${donation.donorName}',
                      subtitle: donation.pickupAddress,
                      phone: donation.donorPhone,
                      isActive: !isPickedUp,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 11),
                      child: Container(
                        width: 2,
                        height: 30,
                        color: AppColors.borderLight,
                      ),
                    ),
                    _buildWaypointRow(
                      icon: Icons.location_on,
                      iconColor: isPickedUp ? AppColors.primaryGreen : AppColors.mutedGrey,
                      title: 'Drop-off: ${donation.claimedByNgoName ?? "Shelter"}',
                      subtitle: donation.dropoffAddress,
                      phone: '+91 98220 54321',
                      isActive: isPickedUp,
                    ),
                    const SizedBox(height: 16),

                    // Launch Maps CTA
                    FBButton(
                      label: 'Open Live Navigation (Google Maps)',
                      variant: FBButtonVariant.secondary,
                      icon: Icons.navigation_outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Launching directions to ${isPickedUp ? donation.dropoffAddress : donation.pickupAddress}...',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // AI Safe Handling Advisory
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.primaryGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AIService().getSafeHandlingAdvisory(donation).title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...AIService().getSafeHandlingAdvisory(donation).handlingTips.take(2).map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('• $tip', style: const TextStyle(fontSize: 12, color: AppColors.charcoal)),
                        )),
                    const SizedBox(height: 4),
                    Text(
                      AIService().getSafeHandlingAdvisory(donation).disclaimer,
                      style: TextStyle(fontSize: 10, color: AppColors.mutedGrey.withValues(alpha: 0.8), fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Food Safety Checklist (Before Pickup)
              if (!isPickedUp && donation.isFood) ...[
                Container(
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
                        'On-Site Freshness Verification',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check the cargo physically before taking possession from donor:',
                        style: TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _packagingIntact,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primaryGreen,
                        title: const Text(
                          'Food packaging is sealed, hygienic & leak-proof',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        onChanged: (val) => setState(() => _packagingIntact = val ?? false),
                      ),
                      CheckboxListTile(
                        value: _temperatureChecked,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primaryGreen,
                        title: Text(
                          'Holding condition verified (${donation.storageCondition?.toUpperCase() ?? "AMBIENT"})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        onChanged: (val) => setState(() => _temperatureChecked = val ?? false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Proof of Handover (Phase 2: Deliver to Shelter)
              if (isPickedUp) ...[
                Container(
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
                        'Handover Proof (Optional / As per NGO Policy)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Verify physical receipt slip or cargo transfer before requesting the NGO verification code.',
                        style: TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _proofOfHandoverChecked,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primaryGreen,
                        title: const Text(
                          'Cargo physically inspected and transferred to shelter coordinator',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        onChanged: (val) => setState(() => _proofOfHandoverChecked = val ?? false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Custody Timeline
              DonationStatusTimeline(donation: donation),
              const SizedBox(height: 24),

              // Big Action Button
              if (!isPickedUp)
                FBButton.rider(
                  label: 'ENTER DONOR OTP TO CONFIRM PICKUP',
                  icon: Icons.vpn_key_outlined,
                  isLoading: _isProcessing,
                  onPressed: () => _handleConfirmPickup(donation, donationProvider),
                )
              else
                FBButton.rider(
                  label: 'ENTER NGO OTP TO CONFIRM HANDOVER',
                  icon: Icons.done_all,
                  isLoading: _isProcessing,
                  onPressed: () => _handleConfirmDelivery(donation, donationProvider),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaypointRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? phone,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.charcoal : AppColors.mutedGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? AppColors.charcoal : AppColors.mutedGrey,
                ),
              ),
            ],
          ),
        ),
        if (phone != null)
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: AppColors.primaryGreen, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $phone...')),
              );
            },
          ),
      ],
    );
  }
}
