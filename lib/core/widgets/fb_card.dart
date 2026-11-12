import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FBCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final effectiveBorder = border ??
        const BorderSide(color: AppColors.borderLight, width: 1.0);

    return Card(
      elevation: elevation,
      color: color ?? AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: effectiveBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

