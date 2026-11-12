import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FBLoadingIndicator extends StatelessWidget {
  final String? message;

  const FBLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            strokeWidth: 3.0,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.mutedGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FBSkeletonTile extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const FBSkeletonTile({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: AppColors.borderLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

