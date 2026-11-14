import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Renders the interactive, stylized mobile delivery tracking map
/// matching Image 3 Screen 9:
/// - Street grid background
/// - Red pickup pin (Donor)
/// - Green destination pin (Shelter / NGO)
/// - Curved route line with dashed pattern
/// - Live courier scooter with floating callout: "Pickup in 24 min"
class RouteMapView extends StatelessWidget {
  final double height;
  final String pickupAddress;
  final String destinationAddress;
  final String etaText;
  final VoidCallback? onRefresh;

  const RouteMapView({
    super.key,
    this.height = 280,
    this.pickupAddress = '123 Food Street, Pune',
    this.destinationAddress = 'Asha Shelter, Swargate, Pune',
    this.etaText = 'Pickup in 24 min',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5ECE7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Custom map background with streets, river, and route
            Positioned.fill(
              child: CustomPaint(
                painter: _MapRoutePainter(),
              ),
            ),

            // Top control buttons (GPS / Refresh)
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  _mapButton(
                    icon: Icons.my_location,
                    tooltip: 'Recenter',
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  if (onRefresh != null)
                    _mapButton(
                      icon: Icons.refresh,
                      tooltip: 'Refresh Route',
                      onTap: onRefresh!,
                    ),
                ],
              ),
            ),

            // Courier floating callout badge on the route
            Positioned(
              top: height * 0.28,
              left: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.two_wheeler, size: 16, color: AppColors.primaryGreen),
                        const SizedBox(width: 6),
                        Text(
                          etaText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomPaint(
                    size: const Size(10, 6),
                    painter: _TrianglePainter(color: AppColors.white),
                  ),
                ],
              ),
            ),

            // Bottom overlay indicator with legend
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mintLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Donor Pickup',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward, size: 14, color: AppColors.mutedGrey),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'NGO Shelter',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 18, color: AppColors.charcoal),
        ),
      ),
    );
  }
}

class _MapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Street grid lines
    final streetPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final minorStreetPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw main streets
    canvas.drawLine(Offset(0, h * 0.4), Offset(w, h * 0.35), streetPaint);
    canvas.drawLine(Offset(0, h * 0.7), Offset(w, h * 0.65), streetPaint);
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.35, h), streetPaint);
    canvas.drawLine(Offset(w * 0.7, 0), Offset(w * 0.65, h), streetPaint);

    // Draw minor streets
    canvas.drawLine(Offset(0, h * 0.15), Offset(w, h * 0.2), minorStreetPaint);
    canvas.drawLine(Offset(0, h * 0.85), Offset(w, h * 0.8), minorStreetPaint);
    canvas.drawLine(Offset(w * 0.15, 0), Offset(w * 0.12, h), minorStreetPaint);
    canvas.drawLine(Offset(w * 0.85, 0), Offset(w * 0.82, h), minorStreetPaint);

    // Park / Green zones
    final parkPaint = Paint()
      ..color = const Color(0xFFCCE3D2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.22, w * 0.22, h * 0.15),
        const Radius.circular(8),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.72, h * 0.45, w * 0.22, h * 0.18),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    // Route path (From Donor to Shelter)
    final p1 = Offset(w * 0.18, h * 0.65); // Pickup
    final p2 = Offset(w * 0.45, h * 0.42); // Mid-way turn
    final p3 = Offset(w * 0.82, h * 0.32); // Shelter

    final routeBgPaint = Paint()
      ..color = const Color(0xFF1E88E5).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = const Color(0xFF1E88E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final routePath = Path();
    routePath.moveTo(p1.dx, p1.dy);
    routePath.lineTo(p2.dx, p2.dy);
    routePath.lineTo(p3.dx, p3.dy);

    canvas.drawPath(routePath, routeBgPaint);
    canvas.drawPath(routePath, routePaint);

    // Pin 1: Pickup Pin (Red)
    _drawPin(canvas, p1, AppColors.errorRed, Icons.location_on);

    // Pin 2: Delivery Pin (Green)
    _drawPin(canvas, p3, AppColors.primaryGreen, Icons.flag);
  }

  void _drawPin(Canvas canvas, Offset pos, Color color, IconData icon) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(pos.dx, pos.dy + 4), 10, shadowPaint);

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 11, circlePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(pos, 11, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

