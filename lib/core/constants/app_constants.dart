class AppConstants {
  AppConstants._();

  // Application Info
  static const String appName = 'FoodBridge';
  static const String appTagline = 'Share More. Waste Less. Bridge the Need.';
  static const String appVersion = '1.0.0';

  // Responsive Breakpoints (dp)
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;

  // Touch Target Accessibility Standards (dp)
  static const double minTouchTargetSize = 48.0;
  static const double riderTouchTargetSize = 56.0;

  // Animation Durations
  static const Duration splashDuration = Duration(milliseconds: 1500);
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);

  // Pagination & Lists
  static const int defaultPageSize = 20;

  // Food Safety Limits
  static const int maxCookedFoodHoldingHours = 4;
  static const int urgentExpiryThresholdHours = 3;

  // Asset Directories
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String illustrationsPath = 'assets/illustrations/';
}

