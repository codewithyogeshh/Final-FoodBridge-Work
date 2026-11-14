class EnvConfig {
  static const String appName = 'FoodBridge';
  static const String appTagline = 'Share More. Waste Less. Bridge the Need.';

  // Live Supabase Production Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jmrjslzsztkckopzaatl.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImptcmpzbHpzenRrY2tvcHphYXRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ2MDQwNDMsImV4cCI6MjExMDE4MDA0M30.d8VHTzqsqxuh01e3Vbq2pDHTpJFPaqv2J1rJx8_w2PQ',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl != 'https://placeholder-project.supabase.co' &&
      supabaseAnonKey != 'placeholder-anon-key-to-be-configured';

  // Environment mode
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}

