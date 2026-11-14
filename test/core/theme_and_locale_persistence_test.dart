import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodbridge/core/localization/locale_provider.dart';
import 'package:foodbridge/core/theme/theme_provider.dart';
import 'package:foodbridge/core/widgets/exit_confirmation_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme & Locale Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ThemeProvider defaults to system mode and persists changes', () async {
      final themeProvider = ThemeProvider();
      expect(themeProvider.themeMode, ThemeMode.system);

      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.isDarkMode, isTrue);

      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.isLightMode, isTrue);
    });

    test('LocaleProvider defaults to English and switches to Marathi / Hindi', () async {
      final localeProvider = LocaleProvider();
      expect(localeProvider.locale.languageCode, 'en');

      await localeProvider.setLanguageCode('mr');
      expect(localeProvider.locale.languageCode, 'mr');
      expect(localeProvider.shortName, 'मराठी');

      await localeProvider.setLanguageCode('hi');
      expect(localeProvider.locale.languageCode, 'hi');
      expect(localeProvider.shortName, 'हिंदी');
    });
  });

  group('Exit Confirmation Dialog Tests', () {
    testWidgets('Exit confirmation dialog renders with Marathi text when locale is mr', (tester) async {
      final localeProvider = LocaleProvider();
      await localeProvider.setLanguageCode('mr');

      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: const Locale('mr'),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showExitConfirmationDialog(context),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('FoodBridge मधून बाहेर पडायचे?'), findsOneWidget);
      expect(find.text('तुम्हाला खरंच FoodBridge ॲपमधून बाहेर पडायचे आहे का?'), findsOneWidget);
      expect(find.text('नाही'), findsOneWidget);
      expect(find.text('होय, बाहेर पडा'), findsOneWidget);

      // Tap 'नाही' (Cancel) to dismiss without popping app
      await tester.tap(find.text('नाही'));
      await tester.pumpAndSettle();

      expect(find.text('FoodBridge मधून बाहेर पडायचे?'), findsNothing);
    });
  });
}
