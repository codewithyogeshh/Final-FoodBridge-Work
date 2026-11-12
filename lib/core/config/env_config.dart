class EnvConfig {
  static const String appName = 'FoodBridge';
  static const String appTagline = 'Share More. Waste Less. Bridge the Need.';

  // Supabase Configuration
  // Can be overridden at build time using:
  // flutter run --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=...
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key-to-be-configured',
  );

  static bool get isConfigured =>
      supabaseUrl != 'https://placeholder-project.supabase.co' &&
      supabaseAnonKey != 'placeholder-anon-key-to-be-configured';

  // Environment mode
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}
