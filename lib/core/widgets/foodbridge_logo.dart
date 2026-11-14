import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The official FoodBridge Brand Logo Widget.
/// Renders the iconic green heart emblem cradling sharing hands and fork & knife,
/// along with the brand title and mission tagline.
class FoodBridgeLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final String? customTagline;
  final bool isLight;
  final bool horizontal;

  const FoodBridgeLogo({
    super.key,
    this.size = 48,
    this.showTagline = true,
    this.customTagline,
    this.isLight = false,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isLight ? AppColors.white : AppColors.deepGreen;
    final taglineColor = isLight ? AppColors.white.withOpacity(0.85) : AppColors.mutedGrey;
    final tagline = customTagline ?? 'Share Food • Spread Kindness';

    final emblem = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: (isLight ? Colors.black : AppColors.primaryGreen).withValues(alpha: 0.15),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.06),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          'assets/images/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: isLight ? AppColors.white : AppColors.primaryGreen,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  size: size * 0.65,
                  color: isLight ? AppColors.primaryGreen : AppColors.white,
                ),
                Positioned(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: size * 0.35,
                    color: isLight ? AppColors.white : AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          emblem,
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FoodBridge',
                style: TextStyle(
                  fontSize: size * 0.48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: titleColor,
                ),
              ),
              if (showTagline)
                Text(
                  tagline,
                  style: TextStyle(
                    fontSize: (size * 0.22).clamp(10.0, 13.0),
                    fontWeight: FontWeight.w500,
                    color: taglineColor,
                  ),
                ),
            ],
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        SizedBox(height: size * 0.2),
        Text(
          'FoodBridge',
          style: TextStyle(
            fontSize: size * 0.46,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: titleColor,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            tagline,
            style: TextStyle(
              fontSize: (size * 0.24).clamp(11.0, 14.0),
              fontWeight: FontWeight.w500,
              color: taglineColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
