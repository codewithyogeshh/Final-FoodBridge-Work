import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom illustration of a volunteer riding a green electric delivery scooter
/// with a FoodBridge cargo box on the back. Matches Image 1 Screen 2 & Screen 4.
class ScooterCourierIllustration extends StatelessWidget {
  final double size;

  const ScooterCourierIllustration({
    super.key,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ScooterCourierPainter(),
      ),
    );
  }
}

class _ScooterCourierPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Scooter Wheels
    final wheelPaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.fill;
    final rimPaint = Paint()
      ..color = const Color(0xFFCFD8DC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Back Wheel
    canvas.drawCircle(const Offset(22, 78), 12, wheelPaint);
    canvas.drawCircle(const Offset(22, 78), 7, rimPaint);

    // Front Wheel
    canvas.drawCircle(const Offset(78, 78), 12, wheelPaint);
    canvas.drawCircle(const Offset(78, 78), 7, rimPaint);

    // 2. Scooter Body / Chassis (Vibrant Eco Green)
    final chassisPaint = Paint()
      ..color = const Color(0xFF1E824C)
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    bodyPath.moveTo(20, 76);
    bodyPath.lineTo(44, 76); // Footboard
    bodyPath.lineTo(48, 62);
    bodyPath.lineTo(70, 52); // Front stem angle
    bodyPath.lineTo(76, 76);
    bodyPath.lineTo(82, 74);
    bodyPath.lineTo(74, 46);
    bodyPath.lineTo(66, 48);
    bodyPath.lineTo(42, 60);
    bodyPath.lineTo(24, 60);
    bodyPath.close();
    canvas.drawPath(bodyPath, chassisPaint);

    // Handlebar
    final handlePaint = Paint()
      ..color = const Color(0xFF263238)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(68, 44), const Offset(62, 42), handlePaint);

    // 3. Delivery Cargo Box on Back Rack (Yellow / Warm Amber with FoodBridge heart)
    final boxPaint = Paint()
      ..color = const Color(0xFFF39C12)
      ..style = PaintingStyle.fill;
    final boxRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 42, 24, 22),
      const Radius.circular(5),
    );
    canvas.drawRRect(boxRRect, boxPaint);

    // Small Heart Logo on Box
    final boxLogoPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final heartPath = Path();
    heartPath.moveTo(22, 56);
    heartPath.cubicTo(18, 52, 18, 48, 22, 50);
    heartPath.cubicTo(26, 48, 26, 52, 22, 56);
    canvas.drawPath(heartPath, boxLogoPaint);

    // 4. Rider Body (Volunteer in Green Outfit and Helmet)
    final riderCloth = Paint()
      ..color = const Color(0xFF27AE60)
      ..style = PaintingStyle.fill;

    // Torso leaning forward
    final torsoPath = Path();
    torsoPath.moveTo(34, 58); // sitting on seat
    torsoPath.lineTo(48, 42); // shoulder
    torsoPath.lineTo(44, 38);
    torsoPath.lineTo(30, 54);
    torsoPath.close();
    canvas.drawPath(torsoPath, riderCloth);

    // Arms extending to handlebar
    final armPaint = Paint()
      ..color = const Color(0xFF27AE60)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(46, 42), const Offset(62, 44), armPaint);

    // Head / Helmet (Green helmet with visor)
    final helmetPaint = Paint()
      ..color = const Color(0xFF1E824C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(48, 28), 9, helmetPaint);

    // Helmet Visor (Tinted black)
    final visorPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.fill;
    final visorPath = Path();
    visorPath.addArc(
      const Rect.fromLTWH(48, 24, 10, 8),
      -math.pi / 4,
      math.pi / 2,
    );
    canvas.drawPath(visorPath, visorPaint);

    // Legs on footboard
    final legPaint = Paint()
      ..color = const Color(0xFF1B4F72) // Navy pants
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final legPath = Path();
    legPath.moveTo(34, 58);
    legPath.lineTo(46, 68);
    legPath.lineTo(54, 74);
    canvas.drawPath(legPath, legPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
