import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../donations/domain/models/donation.dart';

/// Modal displaying the unique dynamic QR code for NGO shelter delivery verification.
/// The volunteer scans this code to verify handover and complete the mission.
void showNgoHandoverQrModal(BuildContext context, Donation donation) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final qrPayload = 'foodbridge://verify?id=${donation.id}&otp=${donation.deliveryOtp}&shelter=${Uri.encodeComponent(donation.claimedByNgoName ?? 'Shelter')}';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_2, color: AppColors.primaryGreen, size: 28),
              SizedBox(width: 8),
              Text(
                'Shelter Handover QR',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Show this QR code to the volunteer when they arrive with: ${donation.title}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey),
          ),
          const SizedBox(height: 20),

          // Dynamic QR Code Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryGreen, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: qrPayload,
              version: QrVersions.auto,
              size: 200,
              gapless: true,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primaryGreen,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Numeric Code Fallback
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.surfaceDark : AppColors.mintLight),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.key, size: 18, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                const Text('4-Digit Code: ', style: TextStyle(fontSize: 13, color: AppColors.mutedGrey)),
                Text(
                  donation.deliveryOtp.isNotEmpty ? donation.deliveryOtp : '9354',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Close QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  ),
);
}
