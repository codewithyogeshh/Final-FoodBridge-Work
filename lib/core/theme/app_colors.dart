import 'package:flutter/material.dart';

/// FoodBridge Design System Colors
/// Clean, accessible, professional palette designed for ease of use by all citizens.
/// Features a true neutral dark theme (no green tint) and restrained, calm accents.
class AppColors {
  AppColors._();

  // Core Brand Palette (Clean, restrained emerald green)
  static const Color primaryGreen = Color(0xFF1E7E4E);
  static const Color deepGreen = Color(0xFF14532D);
  static const Color warmCream = Color(0xFFF8F9FA); // Clean neutral off-white
  static const Color charcoal = Color(0xFF1F2937);
  static const Color mutedGrey = Color(0xFF6B7280);
  static const Color orange = Color(0xFFD97706);
  static const Color warningOrange = Color(0xFFD97706);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color white = Color(0xFFFFFFFF);
  static const Color mintLight = Color(0xFFF0FDF4);

  // Surface & Borders (Light)
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderGrey = Color(0xFFE5E7EB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F9FA);

  // True Neutral Dark Theme Palette (No green tint, standard clean dark slate)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color borderDark = Color(0xFF2E2E2E);
  static const Color primaryAccentDark = Color(0xFF2E9E66);
  static const Color textDarkPrimary = Color(0xFFF9FAFB);
  static const Color textDarkSecondary = Color(0xFF9CA3AF);

  // Status Tints (Subtle, calm, professional - not loud/rainbow)
  static const Color statusDraftBg = Color(0xFFF3F4F6);
  static const Color statusDraftText = Color(0xFF4B5563);

  static const Color statusAvailableBg = Color(0xFFECFDF5);
  static const Color statusAvailableText = Color(0xFF065F46);

  static const Color statusRequestedBg = Color(0xFFF0F9FF);
  static const Color statusRequestedText = Color(0xFF0369A1);

  static const Color statusAcceptedBg = Color(0xFFF0FDF4);
  static const Color statusAcceptedText = Color(0xFF15803D);

  static const Color statusAssignedBg = Color(0xFFFAF5FF);
  static const Color statusAssignedText = Color(0xFF6B21A8);

  static const Color statusInTransitBg = Color(0xFFFFFBEB);
  static const Color statusInTransitText = Color(0xFFB45309);

  static const Color statusDeliveredBg = Color(0xFFF0FDFA);
  static const Color statusDeliveredText = Color(0xFF0F766E);

  static const Color statusCompletedBg = Color(0xFFECFDF5);
  static const Color statusCompletedText = Color(0xFF047857);

  static const Color statusCancelledBg = Color(0xFFFEF2F2);
  static const Color statusCancelledText = Color(0xFF991B1B);

  static const Color statusExpiredBg = Color(0xFFFEF2F2);
  static const Color statusExpiredText = Color(0xFFB91C1C);

  static const Color statusRejectedBg = Color(0xFFFFF1F2);
  static const Color statusRejectedText = Color(0xFF9F1239);
}
