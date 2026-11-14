import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom illustration of a volunteer wearing a green cap and shirt with "VOLUNTEER"
/// holding a FoodBridge donation box against an eco-city skyline.
/// Matches Image 1 Screen 1 (Be a Volunteer).
class VolunteerHeroIllustration extends StatelessWidget {
  final double width;
  final double height;

  const VolunteerHeroIllustration({
    super.key,
    this.width = double.infinity,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _VolunteerHeroPainter(),
      ),
    );
  }
}

class _VolunteerHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft radial background glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.8,
        colors: [
          AppColors.primaryGreen.withOpacity(0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), glowPaint);

    // 2. City Skyline Silhouette in background
    final cityPaint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final cityPath = Path();
    cityPath.moveTo(0, h * 0.75);
    cityPath.lineTo(w * 0.08, h * 0.75);
    cityPath.lineTo(w * 0.08, h * 0.62);
    cityPath.lineTo(w * 0.16, h * 0.62);
    cityPath.lineTo(w * 0.16, h * 0.70);
    cityPath.lineTo(w * 0.22, h * 0.70);
    cityPath.lineTo(w * 0.22, h * 0.58);
    cityPath.lineTo(w * 0.30, h * 0.58);
    cityPath.lineTo(w * 0.30, h * 0.68);
    cityPath.lineTo(w * 0.38, h * 0.68);
    cityPath.lineTo(w * 0.38, h * 0.52);
    cityPath.lineTo(w * 0.44, h * 0.52);
    cityPath.lineTo(w * 0.44, h * 0.65);
    cityPath.lineTo(w * 0.52, h * 0.65);
    cityPath.lineTo(w * 0.52, h * 0.55);
    cityPath.lineTo(w * 0.60, h * 0.55);
    cityPath.lineTo(w * 0.60, h * 0.68);
    cityPath.lineTo(w * 0.70, h * 0.68);
    cityPath.lineTo(w * 0.70, h * 0.60);
    cityPath.lineTo(w * 0.82, h * 0.60);
    cityPath.lineTo(w * 0.82, h * 0.72);
    cityPath.lineTo(w, h * 0.72);
    cityPath.lineTo(w, h);
    cityPath.lineTo(0, h);
    cityPath.close();
    canvas.drawPath(cityPath, cityPaint);

    // 3. Floating Eco Leaves
    final leafPaint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    void drawLeaf(double cx, double cy, double scale, double rotation) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation);
      final p = Path();
      p.moveTo(0, -14 * scale);
      p.quadraticBezierTo(10 * scale, -8 * scale, 12 * scale, 6 * scale);
      p.quadraticBezierTo(2 * scale, 14 * scale, 0, 16 * scale);
      p.quadraticBezierTo(-2 * scale, 14 * scale, -12 * scale, 6 * scale);
      p.quadraticBezierTo(-10 * scale, -8 * scale, 0, -14 * scale);
      canvas.drawPath(p, leafPaint);
      canvas.restore();
    }

    drawLeaf(w * 0.12, h * 0.35, 1.2, -0.4);
    drawLeaf(w * 0.18, h * 0.22, 0.8, -0.8);
    drawLeaf(w * 0.85, h * 0.30, 1.3, 0.5);
    drawLeaf(w * 0.80, h * 0.45, 0.9, 0.8);

    // 4. Center Volunteer Figure (Facing slightly three-quarter back holding box)
    final centerX = w * 0.48;
    final headY = h * 0.34;

    // Green Cap & Head
    final capPaint = Paint()
      ..color = AppColors.deepGreen
      ..style = PaintingStyle.fill;

    final skinPaint = Paint()
      ..color = const Color(0xFFD4A373)
      ..style = PaintingStyle.fill;

    // Neck & Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, headY), width: 44, height: 50),
      skinPaint,
    );

    // Green Volunteer Cap
    final capPath = Path();
    capPath.addArc(
      Rect.fromCenter(center: Offset(centerX, headY - 8), width: 48, height: 42),
      math.pi,
      math.pi,
    );
    // Cap Visor pointing forward right
    capPath.quadraticBezierTo(centerX + 32, headY - 10, centerX + 36, headY - 4);
    capPath.lineTo(centerX + 24, headY);
    capPath.close();
    canvas.drawPath(capPath, capPaint);

    // Volunteer Green T-Shirt / Torso
    final shirtPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    bodyPath.moveTo(centerX - 36, headY + 28);
    bodyPath.quadraticBezierTo(centerX, headY + 22, centerX + 36, headY + 28);
    bodyPath.lineTo(centerX + 48, h * 0.85);
    bodyPath.lineTo(centerX - 48, h * 0.85);
    bodyPath.close();
    canvas.drawPath(bodyPath, shirtPaint);

    // "VOLUNTEER" Text on back of shirt
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'VOLUNTEER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, headY + 54),
    );

    // 5. Cardboard Donation Box held by volunteer
    final boxPaint = Paint()
      ..color = const Color(0xFFC89D66) // Warm cardboard
      ..style = PaintingStyle.fill;

    final boxShadowPaint = Paint()
      ..color = const Color(0xFFA87C49)
      ..style = PaintingStyle.fill;

    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX + 18, headY + 45, 68, 56),
      const Radius.circular(8),
    );
    canvas.drawRRect(boxRect, boxPaint);

    // Box Flap shadow
    final flapPath = Path();
    flapPath.moveTo(centerX + 18, headY + 45);
    flapPath.lineTo(centerX + 86, headY + 45);
    flapPath.lineTo(centerX + 86, headY + 54);
    flapPath.lineTo(centerX + 18, headY + 54);
    flapPath.close();
    canvas.drawPath(flapPath, boxShadowPaint);

    // Heart Emblem on Box
    final heartPaint = Paint()
      ..color = AppColors.deepGreen
      ..style = PaintingStyle.fill;

    final heartCenter = Offset(centerX + 52, headY + 74);
    final heartPath = Path();
    heartPath.moveTo(heartCenter.dx, heartCenter.dy + 8);
    heartPath.cubicTo(
      heartCenter.dx - 12, heartCenter.dy - 2,
      heartCenter.dx - 12, heartCenter.dy - 12,
      heartCenter.dx, heartCenter.dy - 6,
    );
    heartPath.cubicTo(
      heartCenter.dx + 12, heartCenter.dy - 12,
      heartCenter.dx + 12, heartCenter.dy - 2,
      heartCenter.dx, heartCenter.dy + 8,
    );
    canvas.drawPath(heartPath, heartPaint);

    // Volunteer Arms holding the box
    final armPaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rightArm = Path();
    rightArm.moveTo(centerX + 32, headY + 36);
    rightArm.quadraticBezierTo(centerX + 52, headY + 56, centerX + 34, headY + 76);
    canvas.drawPath(rightArm, armPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

