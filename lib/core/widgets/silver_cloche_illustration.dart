import 'package:flutter/material.dart';

/// Renders the iconic silver cloche / food serving platter from the FoodBridge
/// Restaurant Donor hero card (as shown in reference designs).
class SilverClocheIllustration extends StatelessWidget {
  final double size;

  const SilverClocheIllustration({
    super.key,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.75),
      painter: _ClochePainter(),
    );
  }
}

class _ClochePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dome gradient
    final domePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFE2E8F0),
          Color(0xFFCBD5E1),
          Color(0xFF94A3B8),
        ],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.2, w * 0.7, h * 0.55))
      ..style = PaintingStyle.fill;

    // Handle at top
    final handlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFF94A3B8)],
      ).createShader(Rect.fromLTWH(w * 0.44, h * 0.08, w * 0.12, h * 0.15))
      ..style = PaintingStyle.fill;

    // Platter base
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFCBD5E1), Color(0xFF64748B)],
      ).createShader(Rect.fromLTWH(0, h * 0.72, w, h * 0.15))
      ..style = PaintingStyle.fill;

    // Handle knob
    canvas.drawCircle(Offset(w * 0.5, h * 0.16), w * 0.06, handlePaint);

    // Dome path
    final domePath = Path();
    domePath.moveTo(w * 0.15, h * 0.72);
    domePath.cubicTo(
      w * 0.15,
      h * 0.25,
      w * 0.85,
      h * 0.25,
      w * 0.85,
      h * 0.72,
    );
    domePath.close();
    canvas.drawPath(domePath, domePaint);

    // Dome highlight sheen
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.6),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(w * 0.25, h * 0.3, w * 0.2, h * 0.35))
      ..style = PaintingStyle.fill;

    final sheenPath = Path();
    sheenPath.moveTo(w * 0.28, h * 0.65);
    sheenPath.cubicTo(
      w * 0.28,
      h * 0.35,
      w * 0.45,
      h * 0.32,
      w * 0.45,
      h * 0.65,
    );
    sheenPath.close();
    canvas.drawPath(sheenPath, sheenPaint);

    // Platter base ellipse
    final platterRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, h * 0.70, w * 0.9, h * 0.12),
      const Radius.circular(8),
    );
    canvas.drawRRect(platterRect, basePaint);

    // Platter rim lip
    final lipPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(w * 0.06, h * 0.72),
      Offset(w * 0.94, h * 0.72),
      lipPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

