import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-screen real-time Camera QR Scanner for Volunteer Handover Verification.
/// Uses the device camera with MobileScanner to scan dynamic NGO QR codes in real-time.
class QrCameraScannerView extends StatefulWidget {
  final Function(String rawPayload) onScanned;
  final String? expectedDonationId;
  final String? targetNgoName;

  const QrCameraScannerView({
    super.key,
    required this.onScanned,
    this.expectedDonationId,
    this.targetNgoName,
  });

  @override
  State<QrCameraScannerView> createState() => _QrCameraScannerViewState();
}

class _QrCameraScannerViewState extends State<QrCameraScannerView>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _animController;
  late final Animation<double> _scanLineAnimation;
  bool _hasScanned = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.trim().isNotEmpty) {
        _hasScanned = true;
        HapticFeedback.mediumImpact();
        _controller.stop();
        Navigator.of(context).pop();
        widget.onScanned(raw.trim());
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shelterName = widget.targetNgoName ?? 'NGO Shelter';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Camera Preview via MobileScanner
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              fit: BoxFit.cover,
              errorBuilder: (ctx, error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Camera Access Required',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please grant camera permission to scan NGO handover QR codes directly.\nError: ${error.errorCode}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Quick verification fallback
                            Navigator.of(context).pop();
                            widget.onScanned('foodbridge://verify?id=${widget.expectedDonationId ?? ""}&otp=0000');
                          },
                          icon: const Icon(Icons.flash_on),
                          label: const Text('Simulate Handover Scan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Dark Vignette Mask with Center Cutout
          Positioned.fill(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final boxSize = constraints.maxWidth * 0.72;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Scanner Box Outline
                    Container(
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primaryGreen,
                          width: 3.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Laser Scanning Line Animation
                          AnimatedBuilder(
                            animation: _scanLineAnimation,
                            builder: (context, child) {
                              return Positioned(
                                top: boxSize * _scanLineAnimation.value,
                                left: 12,
                                right: 12,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34D399),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF34D399).withOpacity(0.8),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scan NGO Handover QR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Align QR code on $shelterName\'s screen',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Torch Toggle
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: Icon(
                          _torchOn ? Icons.flash_on : Icons.flash_off,
                          color: _torchOn ? const Color(0xFFFBBF24) : Colors.white,
                        ),
                        onPressed: () async {
                          await _controller.toggleTorch();
                          setState(() => _torchOn = !_torchOn);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Flip Camera
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                        onPressed: () => _controller.switchCamera(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Instruction Banner & Quick-Simulate Helper
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner, color: AppColors.primaryGreen, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Point camera at the NGO screen QR code',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quick-Simulate Button (for testing or single device)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onScanned('foodbridge://verify?id=${widget.expectedDonationId ?? ""}&otp=0000');
                      },
                      icon: const Icon(Icons.bolt, size: 16, color: Colors.white70),
                      label: const Text(
                        'Simulate Handover QR Scan',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
