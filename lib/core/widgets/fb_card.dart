import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Production FBCard with:
/// - Realtime Colors 60-30-10 Token System (Light/Dark adaptive)
/// - Animate Spring Micro-Interaction (tactile scale on pointer-down)
class FBCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final BorderSide? border;
  final double borderRadius;
  final double elevation;

  const FBCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
    this.borderRadius = 14.0,
    this.elevation = 0.0,
  });

  @override
  State<FBCard> createState() => _FBCardState();
}

class _FBCardState extends State<FBCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorder = widget.border ??
        BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        );
    final effectiveColor = widget.color ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    final cardWidget = Card(
      elevation: widget.elevation,
      color: effectiveColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        side: effectiveBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.onTap != null
          ? InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(16.0),
                child: widget.child,
              ),
            )
          : Padding(
              padding: widget.padding ?? const EdgeInsets.all(16.0),
              child: widget.child,
            ),
    );

    if (widget.onTap == null) {
      return cardWidget;
    }

    return Listener(
      onPointerDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onPointerUp: (_) {
        if (mounted) setState(() => _isPressed = false);
      },
      onPointerCancel: (_) {
        if (mounted) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: cardWidget,
      ),
    );
  }
}
