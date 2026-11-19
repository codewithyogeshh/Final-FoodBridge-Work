import 'package:flutter/material.dart';

/// FoodBridge Design System Colors
/// Clean, accessible, professional palette designed for ease of use by all citizens.
/// Strict adherence to Realtime Colors 60-30-10 Rule:
/// - 60% Dominant Base: Canvas (#F8FAFC Light, #0B0F17 Dark)
/// - 30% Structural Hierarchy: Cards & Modals (#FFFFFF Light, #131B26 Dark), Borders (#E2E8F0 / #223046)
/// - 10% High-Impact Accent: Emerald Green (#059669 / #10B981) + Warm Amber (#F59E0B)
class AppColors {
  AppColors._();

  // Core Brand Palette (Sustainable Emerald Green, meets WCAG AAA/AA)
  static const Color primaryGreen = Color(0xFF1E7E4E);
  static const Color deepGreen = Color(0xFF14532D);
  static const Color emeraldLight = Color(0xFFECFDF5);
  static const Color warmCream = Color(0xFFF8FAFC);
  static const Color charcoal = Color(0xFF0F172A);
  static const Color mutedGrey = Color(0xFF64748B);
  static const Color orange = Color(0xFFD97706);
  static const Color amberWarm = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color warningOrange = Color(0xFFD97706);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color white = Color(0xFFFFFFFF);
  static const Color mintLight = Color(0xFFF0FDF4);
  static const Color skyBlue = Color(0xFF0284C7);
  static const Color skyLight = Color(0xFFF0F9FF);

  // Surface & Borders (Light) - 60-30-10 Scaffolding
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);

  // True Neutral Dark Theme Palette (Rich Midnight Obsidian, no muddy tint)
  static const Color backgroundDark = Color(0xFF0B0F17);
  static const Color surfaceDark = Color(0xFF131B26);
  static const Color cardDark = Color(0xFF131B26);
  static const Color borderDark = Color(0xFF223046);
  static const Color primaryAccentDark = Color(0xFF10B981);
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);

  // Status Tints (Subtle, calm, professional)
  static const Color statusDraftBg = Color(0xFFF1F5F9);
  static const Color statusDraftText = Color(0xFF475569);

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
