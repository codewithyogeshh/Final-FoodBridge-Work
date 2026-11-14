import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom illustration showing community volunteer silhouettes with arms raised,
/// eco leaves, and a green gradient background. Matches Image 2 Screen 2 (Your Impact).
class CommunitySilhouettesIllustration extends StatelessWidget {
  final double height;

  const CommunitySilhouettesIllustration({
    super.key,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _CommunitySilhouettesPainter(),
      ),
    );
  }
}

class _CommunitySilhouettesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background gradient with soft hills
    final hillPaint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final hillPath = Path();
    hillPath.moveTo(0, h * 0.7);
    hillPath.quadraticBezierTo(w * 0.3, h * 0.5, w * 0.6, h * 0.65);
    hillPath.quadraticBezierTo(w * 0.85, h * 0.75, w, h * 0.6);
    hillPath.lineTo(w, h);
    hillPath.lineTo(0, h);
    hillPath.close();
    canvas.drawPath(hillPath, hillPaint);

    // 2. City Skyline in light green behind crowd
    final cityPaint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final cityPath = Path();
    cityPath.moveTo(0, h * 0.6);
    cityPath.lineTo(w * 0.1, h * 0.6);
    cityPath.lineTo(w * 0.1, h * 0.45);
    cityPath.lineTo(w * 0.18, h * 0.45);
    cityPath.lineTo(w * 0.18, h * 0.55);
    cityPath.lineTo(w * 0.28, h * 0.55);
    cityPath.lineTo(w * 0.28, h * 0.4);
    cityPath.lineTo(w * 0.36, h * 0.4);
    cityPath.lineTo(w * 0.36, h * 0.52);
    cityPath.lineTo(w * 0.46, h * 0.52);
    cityPath.lineTo(w * 0.46, h * 0.38);
    cityPath.lineTo(w * 0.54, h * 0.38);
    cityPath.lineTo(w * 0.54, h * 0.5);
    cityPath.lineTo(w * 0.66, h * 0.5);
    cityPath.lineTo(w * 0.66, h * 0.42);
    cityPath.lineTo(w * 0.74, h * 0.42);
    cityPath.lineTo(w * 0.74, h * 0.56);
    cityPath.lineTo(w * 0.88, h * 0.56);
    cityPath.lineTo(w * 0.88, h * 0.48);
    cityPath.lineTo(w, h * 0.48);
    cityPath.lineTo(w, h);
    cityPath.lineTo(0, h);
    cityPath.close();
    canvas.drawPath(cityPath, cityPaint);

    // 3. Silhouette of people with hands joined / raised
    final silhouettePaint = Paint()
      ..color = AppColors.deepGreen
      ..style = PaintingStyle.fill;

    // We draw multiple people silhouettes across the bottom width
    final peopleCount = 7;
    final spacing = w / (peopleCount + 1);

    for (int i = 1; i <= peopleCount; i++) {
      final px = spacing * i;
      final py = h * 0.62 + (i % 2 == 0 ? 10 : 0);
      final headRadius = 14.0;

      // Head
      canvas.drawCircle(Offset(px, py), headRadius, silhouettePaint);

      // Shoulders & Torso
      final bodyPath = Path();
      bodyPath.moveTo(px - 18, py + 16);
      bodyPath.quadraticBezierTo(px, py + 12, px + 18, py + 16);
      bodyPath.lineTo(px + 24, h);
      bodyPath.lineTo(px - 24, h);
      bodyPath.close();
      canvas.drawPath(bodyPath, silhouettePaint);

      // Raised / Celebratory Arms
      final armPaint = Paint()
        ..color = AppColors.deepGreen
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (i % 2 == 1) {
        // Arms raised upwards in celebration
        final leftArm = Path();
        leftArm.moveTo(px - 16, py + 18);
        leftArm.quadraticBezierTo(px - 26, py - 4, px - 22, py - 20);
        canvas.drawPath(leftArm, armPaint);

        final rightArm = Path();
        rightArm.moveTo(px + 16, py + 18);
        rightArm.quadraticBezierTo(px + 26, py - 4, px + 22, py - 20);
        canvas.drawPath(rightArm, armPaint);
      } else {
        // Holding hands with neighbors
        final leftArm = Path();
        leftArm.moveTo(px - 16, py + 18);
        leftArm.quadraticBezierTo(px - 32, py + 12, px - spacing * 0.45, py + 18);
        canvas.drawPath(leftArm, armPaint);
      }
    }

    // 4. Large Eco Leaves framing bottom left & bottom right
    final leafPaint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    void drawEcoLeaf(double startX, double startY, double endX, double endY, double curve) {
      final p = Path();
      p.moveTo(startX, startY);
      p.quadraticBezierTo((startX + endX) / 2 + curve, (startY + endY) / 2 - curve, endX, endY);
      p.quadraticBezierTo((startX + endX) / 2 - curve, (startY + endY) / 2 + curve, startX, startY);
      canvas.drawPath(p, leafPaint);
    }

    drawEcoLeaf(0, h, w * 0.16, h * 0.4, 25);
    drawEcoLeaf(w * 0.05, h, w * 0.22, h * 0.55, -20);
    drawEcoLeaf(w, h, w * 0.84, h * 0.42, -25);
    drawEcoLeaf(w * 0.95, h, w * 0.78, h * 0.58, 20);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

