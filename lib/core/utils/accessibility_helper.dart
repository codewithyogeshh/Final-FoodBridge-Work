import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../constants/app_constants.dart';

class AccessibilityHelper {
  AccessibilityHelper._();

  /// Announce a high-priority message to assistive screen readers (TalkBack / VoiceOver)
  static void announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Ensure an interactive element meets minimum WCAG touch target dimensions (48x48dp standard, 56dp rider)
  static Widget ensureMinTouchTarget({
    required Widget child,
    double minSize = AppConstants.minTouchTargetSize,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: Center(child: child),
    );
  }

  /// Check whether the user has enabled bold text or high contrast in OS settings
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.highContrastOf(context);
  }

  /// Check whether user has scaled text significantly (> 1.3x)
  static bool isLargeTextScale(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(14) > 18.0;
  }
}

