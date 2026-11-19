import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../donations/domain/models/donation.dart';

/// Celebratory animated modal dialog shown when a volunteer completes a food rescue mission.
/// Features a spring-bounce checkmark, karma points badge, and an inspiring quote.
class MissionCompletedDialog extends StatefulWidget {
  final Donation? task;

  const MissionCompletedDialog({
    super.key,
    this.task,
  });

  @override
  State<MissionCompletedDialog> createState() => _MissionCompletedDialogState();
}

class _MissionCompletedDialogState extends State<MissionCompletedDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = widget.task;

    final rescueSummary = task != null
        ? 'Great job! You rescued ${task.quantity.toInt()} ${task.unit} from ${task.donorName} and safely delivered to the shelter.'
        : 'Great job! You helped rescue 20 hot meals from Hotel Grand Plaza and delivered to the shelter.';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Spring-Bounce Checkmark with Glowing Rings
            ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen.withOpacity(0.12),
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Heading
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const Text(
                    '🎉 Mission Completed!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded, size: 16, color: Color(0xFFB45309)),
                        SizedBox(width: 6),
                        Text(
                          '+50 Karma Points Awarded',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rescue Details
            Text(
              rescueSummary,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textDarkSecondary : AppColors.mutedGrey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Inspiring Human Quote Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.surfaceDark : const Color(0xFFF0FDF4)).withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: const BorderSide(color: AppColors.primaryGreen, width: 4),
                  top: BorderSide(color: AppColors.primaryGreen.withOpacity(0.15)),
                  right: BorderSide(color: AppColors.primaryGreen.withOpacity(0.15)),
                  bottom: BorderSide(color: AppColors.primaryGreen.withOpacity(0.15)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.format_quote, size: 20, color: AppColors.primaryGreen),
                      SizedBox(width: 4),
                      Text(
                        'अन्न हे पूर्णब्रह्म',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"तुमचे एक पाऊल, आज कोणाची तरी भूक भागवणारे ठरले. तुमचे हे कार्य अनमोल आहे! 💚"',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.charcoal,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/volunteer/activity');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('View Activity', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/volunteer');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
