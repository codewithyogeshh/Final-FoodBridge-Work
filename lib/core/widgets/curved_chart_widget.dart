import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Renders the beautiful green curved spline chart from the FoodBridge
/// Admin and Analytics screens (Image 1, 2, and 3).
class CurvedChartWidget extends StatelessWidget {
  final List<double> dataPoints;
  final List<String> labels;
  final String activeTooltip;
  final int activeIndex;
  final double height;

  const CurvedChartWidget({
    super.key,
    this.dataPoints = const [12, 28, 45, 60, 95, 120, 85, 70, 90, 110, 105, 130],
    this.labels = const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    this.activeTooltip = 'Jun\n₹ 68,540',
    this.activeIndex = 5,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stepX = constraints.maxWidth / (dataPoints.length - 1);
                final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
                final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
                final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

                final posX = activeIndex * stepX;
                final posY = constraints.maxHeight -
                    ((dataPoints[activeIndex] - minVal) / range * (constraints.maxHeight - 30) + 15);

                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ChartPainter(
                          dataPoints: dataPoints,
                          activeIndex: activeIndex,
                        ),
                      ),
                    ),
                    Positioned(
                      left: (posX - 35).clamp(0.0, constraints.maxWidth - 70),
                      top: (posY - 48).clamp(0.0, constraints.maxHeight - 48),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.charcoal,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          activeTooltip,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // X-Axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((label) {
              final isSelected = labels.indexOf(label) == activeIndex;
              return Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primaryGreen : AppColors.mutedGrey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final int activeIndex;

  _ChartPainter({required this.dataPoints, required this.activeIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final w = size.width;
    final h = size.height;

    // Horizontal grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = h * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);
    final stepX = w / (dataPoints.length - 1);

    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = h - ((dataPoints[i] - minVal) / range * (h - 30) + 15);
      points.add(Offset(x, y));
    }

    // Curved Path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Fill Gradient under curve
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, h);
    fillPath.lineTo(points.first.dx, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryGreen.withOpacity(0.35),
          AppColors.primaryGreen.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final linePaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Active Point marker
    if (activeIndex >= 0 && activeIndex < points.length) {
      final activePoint = points[activeIndex];

      final outerDot = Paint()
        ..color = AppColors.primaryGreen.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePoint, 8, outerDot);

      final innerDot = Paint()
        ..color = AppColors.primaryGreen
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePoint, 4.5, innerDot);

      final whiteCenter = Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(activePoint, 2, whiteCenter);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
