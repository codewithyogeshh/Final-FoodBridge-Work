import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Brand Palette
  static const Color primaryGreen = Color(0xFF218C5A);
  static const Color deepGreen = Color(0xFF145A3A);
  static const Color warmCream = Color(0xFFFFF8ED);
  static const Color charcoal = Color(0xFF263238);
  static const Color mutedGrey = Color(0xFF667085);
  static const Color orange = Color(0xFFE69A36);
  static const Color warningOrange = orange;
  static const Color errorRed = Color(0xFFC83D3D);
  static const Color white = Color(0xFFFFFFFF);

  // Surface & Borders (Light)
  static const Color borderLight = Color(0xFFE4E7EC);
  static const Color borderGrey = borderLight;
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFFFF8ED);

  // Dark Theme Palette ("Rider Mode" & Night Operations)
  static const Color backgroundDark = Color(0xFF12181B);
  static const Color surfaceDark = Color(0xFF1E262B);
  static const Color borderDark = Color(0xFF2C373E);
  static const Color primaryAccentDark = Color(0xFF2BB374);
  static const Color textDarkPrimary = Color(0xFFE0E6EB);
  static const Color textDarkSecondary = Color(0xFF9AA5B1);

  // Status Tints (Light Theme)
  static const Color statusDraftBg = Color(0xFFF2F4F7);
  static const Color statusDraftText = Color(0xFF667085);

  static const Color statusAvailableBg = Color(0xFFE8F5E9);
  static const Color statusAvailableText = Color(0xFF218C5A);

  static const Color statusRequestedBg = Color(0xFFE0F2FE);
  static const Color statusRequestedText = Color(0xFF0284C7);

  static const Color statusAcceptedBg = Color(0xFFDCFCE7);
  static const Color statusAcceptedText = Color(0xFF15803D);

  static const Color statusAssignedBg = Color(0xFFF3E8FF);
  static const Color statusAssignedText = Color(0xFF7E22CE);

  static const Color statusInTransitBg = Color(0xFFFEF3C7);
  static const Color statusInTransitText = Color(0xFFD97706);

  static const Color statusDeliveredBg = Color(0xFFCCFBF1);
  static const Color statusDeliveredText = Color(0xFF0D9488);

  static const Color statusCompletedBg = Color(0xFFD1FAE5);
  static const Color statusCompletedText = Color(0xFF047857);

  static const Color statusCancelledBg = Color(0xFFFEE2E2);
  static const Color statusCancelledText = Color(0xFF991B1B);

  static const Color statusExpiredBg = Color(0xFFFEE2E2);
  static const Color statusExpiredText = Color(0xFFDC2626);

  static const Color statusRejectedBg = Color(0xFFFFE4E6);
  static const Color statusRejectedText = Color(0xFFBE123C);
}
