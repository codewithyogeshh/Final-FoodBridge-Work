import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodbridge/main.dart';
import 'package:foodbridge/core/theme/theme_provider.dart';
import 'package:foodbridge/core/localization/locale_provider.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';
import 'package:foodbridge/features/notifications/presentation/notification_provider.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';

void main() {
  testWidgets('FoodBridgeApp smoke test - splash screen and onboarding load', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => DonationProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
        ],
        child: const FoodBridgeApp(),
      ),
    );

    // Initial frame renders splash screen
    expect(find.text('FoodBridge'), findsOneWidget);
    expect(find.text('Share More. Waste Less. Bridge the Need.'), findsOneWidget);

    // Fast-forward past the splash screen timer (1200ms) to onboarding
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify Onboarding / Role selection screen is rendered
    expect(find.text('Select Your Role'), findsOneWidget);
    expect(find.text('Restaurant\nDonor'), findsOneWidget);
    expect(find.text('Normal\nDonor'), findsOneWidget);
    expect(find.text('Volunteer'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
