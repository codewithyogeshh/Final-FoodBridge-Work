import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Renders the eco-friendly green delivery truck driving past an eco-city skyline
/// from the FoodBridge Admin Login screen (Image 2).
class DeliveryTruckIllustration extends StatelessWidget {
  final double width;
  final double height;

  const DeliveryTruckIllustration({
    super.key,
    this.width = double.infinity,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _TruckAndCityPainter(),
      ),
    );
  }
}

class _TruckAndCityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Eco-city silhouette in background
    final skylinePaint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final skylinePath = Path();
    skylinePath.moveTo(0, h * 0.85);
    skylinePath.lineTo(w * 0.1, h * 0.85);
    skylinePath.lineTo(w * 0.1, h * 0.65);
    skylinePath.lineTo(w * 0.18, h * 0.65);
    skylinePath.lineTo(w * 0.18, h * 0.45);
    skylinePath.lineTo(w * 0.28, h * 0.45);
    skylinePath.lineTo(w * 0.28, h * 0.70);
    skylinePath.lineTo(w * 0.38, h * 0.70);
    skylinePath.lineTo(w * 0.38, h * 0.50);
    skylinePath.lineTo(w * 0.46, h * 0.50);
    skylinePath.lineTo(w * 0.46, h * 0.75);
    skylinePath.lineTo(w * 0.58, h * 0.75);
    skylinePath.lineTo(w * 0.58, h * 0.40);
    skylinePath.lineTo(w * 0.68, h * 0.40);
    skylinePath.lineTo(w * 0.68, h * 0.60);
    skylinePath.lineTo(w * 0.76, h * 0.60);
    skylinePath.lineTo(w * 0.76, h * 0.52);
    skylinePath.lineTo(w * 0.86, h * 0.52);
    skylinePath.lineTo(w * 0.86, h * 0.85);
    skylinePath.lineTo(w, h * 0.85);
    skylinePath.lineTo(w, h);
    skylinePath.lineTo(0, h);
    skylinePath.close();
    canvas.drawPath(skylinePath, skylinePaint);

    // Road line
    final roadPaint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, h * 0.88), Offset(w, h * 0.88), roadPaint);

    // Delivery Truck (centered)
    final cx = w * 0.5;
    final cy = h * 0.76;

    // Cargo box
    final cargoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 20, cy - 14), width: 70, height: 46),
      const Radius.circular(8),
    );
    final cargoPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cargoRect, cargoPaint);

    // Heart logo on cargo box
    final heartPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    final heartPath = Path();
    heartPath.moveTo(cx - 20, cy - 18);
    heartPath.cubicTo(cx - 28, cy - 26, cx - 34, cy - 14, cx - 20, cy - 6);
    heartPath.cubicTo(cx - 6, cy - 14, cx - 12, cy - 26, cx - 20, cy - 18);
    heartPath.close();
    canvas.drawPath(heartPath, heartPaint);

    // Cab
    final cabPath = Path();
    cabPath.moveTo(cx + 15, cy + 9);
    cabPath.lineTo(cx + 42, cy + 9);
    cabPath.lineTo(cx + 42, cy - 6);
    cabPath.lineTo(cx + 30, cy - 22);
    cabPath.lineTo(cx + 15, cy - 22);
    cabPath.close();

    final cabPaint = Paint()
      ..color = AppColors.deepGreen
      ..style = PaintingStyle.fill;
    canvas.drawPath(cabPath, cabPaint);

    // Window
    final winPath = Path();
    winPath.moveTo(cx + 18, cy - 7);
    winPath.lineTo(cx + 36, cy - 7);
    winPath.lineTo(cx + 28, cy - 19);
    winPath.lineTo(cx + 18, cy - 19);
    winPath.close();

    final winPaint = Paint()
      ..color = AppColors.mintLight
      ..style = PaintingStyle.fill;
    canvas.drawPath(winPath, winPaint);

    // Headlight beam
    final lightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.amber.withOpacity(0.5),
          Colors.amber.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(cx + 42, cy - 8, 45, 20))
      ..style = PaintingStyle.fill;

    final lightPath = Path();
    lightPath.moveTo(cx + 42, cy - 2);
    lightPath.lineTo(cx + 80, cy - 10);
    lightPath.lineTo(cx + 80, cy + 12);
    lightPath.lineTo(cx + 42, cy + 4);
    lightPath.close();
    canvas.drawPath(lightPath, lightPaint);

    // Wheels
    final wheelPaint = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.fill;
    final rimPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    // Rear wheel
    canvas.drawCircle(Offset(cx - 32, cy + 10), 9, wheelPaint);
    canvas.drawCircle(Offset(cx - 32, cy + 10), 4, rimPaint);

    // Mid wheel
    canvas.drawCircle(Offset(cx - 8, cy + 10), 9, wheelPaint);
    canvas.drawCircle(Offset(cx - 8, cy + 10), 4, rimPaint);

    // Front wheel
    canvas.drawCircle(Offset(cx + 30, cy + 10), 9, wheelPaint);
    canvas.drawCircle(Offset(cx + 30, cy + 10), 4, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

