import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodbridge/main.dart';
import 'package:foodbridge/core/theme/theme_provider.dart';
import 'package:foodbridge/core/localization/locale_provider.dart';

void main() {
  testWidgets('FoodBridgeApp smoke test - splash screen and onboarding load', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const FoodBridgeApp(),
      ),
    );

    // Initial frame renders splash screen
    expect(find.text('FoodBridge'), findsOneWidget);
    expect(find.text('Share More. Waste Less. Bridge the Need.'), findsOneWidget);

    // Fast-forward past the splash screen timer (1500ms) to onboarding
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify Onboarding / Role selection screen is rendered
    expect(find.text('Welcome to FoodBridge'), findsOneWidget);
    expect(find.text('I Want to Donate'), findsOneWidget);
    expect(find.text('We are an NGO / Shelter'), findsOneWidget);
    expect(find.text('I Want to Volunteer'), findsOneWidget);
  });
}
