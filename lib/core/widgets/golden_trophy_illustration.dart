import 'package:flutter/material.dart';

/// Custom illustration of a Golden Trophy with Laurel Wreath for Volunteer Rewards.
/// Matches Image 2 Screen 4 (Rewards & Badges).
class GoldenTrophyIllustration extends StatelessWidget {
  final double size;

  const GoldenTrophyIllustration({
    super.key,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoldenTrophyPainter(),
      ),
    );
  }
}

class _GoldenTrophyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 120.0;
    canvas.save();
    canvas.scale(scale, scale);

    const centerX = 60.0;

    // 1. Laurel Wreath around trophy (Emerald Green)
    final wreathPaint = Paint()
      ..color = const Color(0xFF27AE60)
      ..style = PaintingStyle.fill;

    void drawLeafPair(double cx, double cy, double angle) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      final p = Path();
      p.moveTo(0, -6);
      p.quadraticBezierTo(5, -3, 6, 2);
      p.quadraticBezierTo(1, 6, 0, 7);
      p.quadraticBezierTo(-1, 6, -6, 2);
      p.quadraticBezierTo(-5, -3, 0, -6);
      canvas.drawPath(p, wreathPaint);
      canvas.restore();
    }

    // Left wreath arc
    drawLeafPair(24, 76, -0.6);
    drawLeafPair(16, 60, -0.4);
    drawLeafPair(14, 44, -0.1);
    drawLeafPair(18, 28, 0.3);
    drawLeafPair(28, 16, 0.7);

    // Right wreath arc
    drawLeafPair(96, 76, 0.6);
    drawLeafPair(104, 60, 0.4);
    drawLeafPair(106, 44, 0.1);
    drawLeafPair(102, 28, -0.3);
    drawLeafPair(92, 16, -0.7);

    // 2. Trophy Cup Body (Gold Gradient)
    final cupPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFF39C12),
          Color(0xFFF1C40F),
          Color(0xFFF9E79F),
          Color(0xFFF39C12),
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(const Rect.fromLTWH(30, 20, 60, 50))
      ..style = PaintingStyle.fill;

    // Trophy Cup Bowl
    final cupPath = Path();
    cupPath.moveTo(34, 24);
    cupPath.lineTo(86, 24);
    cupPath.quadraticBezierTo(86, 56, 60, 62);
    cupPath.quadraticBezierTo(34, 56, 34, 24);
    cupPath.close();
    canvas.drawPath(cupPath, cupPaint);

    // Cup Rim
    final rimPaint = Paint()
      ..color = const Color(0xFFD68910)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(32, 20, 56, 6), const Radius.circular(3)),
      rimPaint,
    );

    // 3. Trophy Handles (Left and Right)
    final handlePaint = Paint()
      ..color = const Color(0xFFF39C12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Left Handle
    final leftHandle = Path();
    leftHandle.moveTo(34, 28);
    leftHandle.cubicTo(16, 28, 16, 52, 40, 54);
    canvas.drawPath(leftHandle, handlePaint);

    // Right Handle
    final rightHandle = Path();
    rightHandle.moveTo(86, 28);
    rightHandle.cubicTo(104, 28, 104, 52, 80, 54);
    canvas.drawPath(rightHandle, handlePaint);

    // 4. Trophy Stem & Base
    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFFD68910)
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(55, 62, 10, 16), stemPaint);

    // Stem ring
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(50, 78, 20, 6), const Radius.circular(3)),
      cupPaint,
    );

    // Pedestal / Base (Deep Gold & Bronze)
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB7950B), Color(0xFFD4AC0D), Color(0xFF7D6608)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(40, 84, 40, 16))
      ..style = PaintingStyle.fill;

    final basePath = Path();
    basePath.moveTo(46, 84);
    basePath.lineTo(74, 84);
    basePath.lineTo(80, 98);
    basePath.lineTo(40, 98);
    basePath.close();
    canvas.drawPath(basePath, basePaint);

    // Base Plaque
    final plaquePaint = Paint()
      ..color = const Color(0xFFF9E79F)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(46, 88, 28, 6), const Radius.circular(2)),
      plaquePaint,
    );

    // 5. Star on trophy bowl
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    void drawStar(double cx, double cy, double r) {
      final p = Path();
      p.moveTo(cx, cy - r);
      p.lineTo(cx + r * 0.3, cy - r * 0.3);
      p.lineTo(cx + r, cy);
      p.lineTo(cx + r * 0.3, cy + r * 0.3);
      p.lineTo(cx, cy + r);
      p.lineTo(cx - r * 0.3, cy + r * 0.3);
      p.lineTo(cx - r, cy);
      p.lineTo(cx - r * 0.3, cy - r * 0.3);
      p.close();
      canvas.drawPath(p, starPaint);
    }

    drawStar(centerX, 40, 7);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

