import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A robust, adaptive image widget for donations that gracefully handles:
/// 1. Remote HTTP/HTTPS URLs with loading and error states.
/// 2. Local device files (from Camera or Gallery) with safe File handling.
/// 3. Thematic vector fallbacks when photos are absent or failing to load.
/// 4. Optional full-screen interactive preview on tap.
class DonationImageWidget extends StatelessWidget {
  final String? imageUrl;
  final bool isFood;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final bool enableFullScreenOnTap;
  final String? title;

  const DonationImageWidget({
    super.key,
    required this.imageUrl,
    this.isFood = true,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.enableFullScreenOnTap = false,
    this.title,
  });

  bool get _isRemoteUrl {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  bool get _isTestEnvironment =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  bool get _isLocalFile {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return false;
    if (_isRemoteUrl) return false;
    if (kIsWeb) return false;
    return true;
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: isFood
          ? AppColors.primaryGreen.withOpacity(0.08)
          : AppColors.orange.withOpacity(0.08),
      child: Center(
        child: Icon(
          isFood ? Icons.restaurant_rounded : Icons.checkroom_rounded,
          size: (height != null && height! < 60) ? 22 : 40,
          color: isFood ? AppColors.primaryGreen : AppColors.orange,
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return _buildFallback(context);
    }

    if (_isRemoteUrl) {
      if (_isTestEnvironment) {
        return _buildFallback(context);
      }
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: _isTestEnvironment
            ? null
            : (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: width,
                  height: height,
                  color: Colors.black.withOpacity(0.04),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                );
              },
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    }

    if (_isLocalFile) {
      try {
        final file = File(url);
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(context),
        );
      } catch (_) {
        return _buildFallback(context);
      }
    }

    return _buildFallback(context);
  }

  void _showFullScreen(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.88),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      maxScale: 4.0,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(dialogContext).size.height * 0.70,
                          maxWidth: MediaQuery.of(dialogContext).size.width,
                        ),
                        child: _isRemoteUrl
                            ? Image.network(
                                imageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, err, stack) => _buildFallback(dialogContext),
                              )
                            : Image.file(
                                File(imageUrl!),
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, err, stack) => _buildFallback(dialogContext),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _buildImage(context);

    if (borderRadius != null) {
      content = ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    if (heroTag != null) {
      content = Hero(
        tag: heroTag!,
        child: content,
      );
    }

    if (enableFullScreenOnTap && imageUrl != null && imageUrl!.isNotEmpty) {
      content = GestureDetector(
        onTap: () => _showFullScreen(context),
        child: content,
      );
    }

    return content;
  }
}
