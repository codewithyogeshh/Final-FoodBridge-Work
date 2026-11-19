import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// FBSpotlightCard (Inspired by React Bits SpotlightCard & Apple Motion Primitives)
/// Provides:
/// - Smooth spring press physics (0.98 scale compression on pointer-down)
/// - Ambient gradient accent border
/// - 60-30-10 Dark & Light mode token compliance
/// - Tactile haptic feedback
class FBSpotlightCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;
  final double borderRadius;
  final bool showGlow;

  const FBSpotlightCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.accentColor,
    this.borderRadius = 16.0,
    this.showGlow = false,
  });

  @override
  State<FBSpotlightCard> createState() => _FBSpotlightCardState();
}

class _FBSpotlightCardState extends State<FBSpotlightCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accentColor ?? AppColors.primaryGreen;

    final baseBorderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Listener(
      onPointerDown: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = true);
          HapticFeedback.selectionClick();
        }
      },
      onPointerUp: (_) {
        if (mounted) setState(() => _isPressed = false);
      },
      onPointerCancel: (_) {
        if (mounted) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _isPressed
                  ? accent.withOpacity(0.6)
                  : (widget.showGlow
                      ? accent.withOpacity(0.35)
                      : baseBorderColor),
              width: _isPressed ? 1.5 : 1.0,
            ),
            boxShadow: widget.showGlow && !isDark
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              splashColor: accent.withOpacity(0.1),
              highlightColor: accent.withOpacity(0.05),
              child: Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
