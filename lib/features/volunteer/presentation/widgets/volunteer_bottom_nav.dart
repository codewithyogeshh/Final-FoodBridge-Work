import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/auth_provider.dart';
import '../../../donations/presentation/donation_provider.dart';
import 'mission_completed_dialog.dart';
import 'qr_camera_scanner_view.dart';

/// The official 5-tab Volunteer Bottom Navigation Bar matching the reference mockup.
/// Tabs:
/// 0: Home (/volunteer)
/// 1: Tasks (/volunteer/tasks)
/// 2: Scan (Center prominent QR Action)
/// 3: Activity (/volunteer/activity)
/// 4: Profile (/volunteer/profile)
class VolunteerBottomNav extends StatelessWidget {
  final int currentIndex;

  const VolunteerBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go('/volunteer');
        break;
      case 1:
        context.go('/volunteer/tasks');
        break;
      case 2:
        _showScanQrSheet(context);
        break;
      case 3:
        context.go('/volunteer/activity');
        break;
      case 4:
        context.go('/volunteer/profile');
        break;
    }
  }

  void _showScanQrSheet(BuildContext context) {
    DonationProvider? donationProvider;
    AuthProvider? auth;
    try {
      donationProvider = context.read<DonationProvider>();
      auth = context.read<AuthProvider>();
    } catch (_) {}

    final volunteerId = auth?.user?.id ?? 'usr-vol-301';
    final activeTasks = donationProvider?.getVolunteerActiveTasks(volunteerId) ?? [];
    final activeTask = activeTasks.isNotEmpty ? activeTasks.first : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrCameraScannerView(
          expectedDonationId: activeTask?.id,
          targetNgoName: activeTask?.claimedByNgoName,
          onScanned: (rawPayload) async {
            String? parsedOtp;
            String? parsedId;
            if (rawPayload.startsWith('foodbridge://') || rawPayload.contains('otp=')) {
              final uri = Uri.tryParse(rawPayload);
              parsedOtp = uri?.queryParameters['otp'];
              parsedId = uri?.queryParameters['id'];
            } else if (RegExp(r'^\d{4}$').hasMatch(rawPayload.trim())) {
              parsedOtp = rawPayload.trim();
            }

            final targetId = activeTask?.id ?? parsedId;
            final finalOtp = parsedOtp ?? activeTask?.deliveryOtp ?? '0000';

            if (targetId != null && donationProvider != null) {
              final success = await donationProvider.confirmDeliveryWithOtp(
                donationId: targetId,
                enteredOtp: finalOtp,
              );
              if (context.mounted && success) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => MissionCompletedDialog(task: activeTask),
                );
              }
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('QR Scanned: $rawPayload. No matching mission found.'),
                  backgroundColor: AppColors.orange,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home, 'Home'),
              _buildNavItem(context, 1, Icons.assignment_outlined, 'Tasks'),
              // Center Scan QR Button
              GestureDetector(
                onTap: () => _onTap(context, 2),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              _buildNavItem(context, 3, Icons.insert_chart_outlined, 'Activity'),
              _buildNavItem(context, 4, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryGreen : AppColors.mutedGrey;

    return InkWell(
      onTap: () => _onTap(context, index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

