import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodbridge/core/localization/locale_provider.dart';
import 'package:foodbridge/core/theme/app_theme.dart';
import 'package:foodbridge/core/theme/theme_provider.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';
import 'package:foodbridge/features/ngo/presentation/ngo_dashboard_screen.dart';
import 'package:foodbridge/features/notifications/presentation/notification_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tapping Icons.translate in NgoDashboardScreen opens language sheet and changes locale to Marathi & Hindi', (tester) async {
    final localeProvider = LocaleProvider();
    final authProvider = AuthProvider();
    await authProvider.login(email: 'ngo@foodbridge.org', password: 'Password123!');
    await authProvider.acceptTerms();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: localeProvider),
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider(create: (_) => DonationProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const NgoDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial English content
    expect(find.byIcon(Icons.translate), findsOneWidget);
    expect(find.text('NGO Portal'), findsOneWidget);
    expect(find.text('Claims'), findsOneWidget);
    expect(find.text('Distributions'), findsOneWidget);

    // Tap translate icon
    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();

    // Verify language bottom sheet is displayed
    expect(find.text('मराठी (Marathi)'), findsOneWidget);
    expect(find.text('हिंदी (Hindi)'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    // Tap Marathi option
    await tester.tap(find.text('मराठी (Marathi)'));
    await tester.pumpAndSettle();

    // Verify locale switched to Marathi
    expect(localeProvider.locale.languageCode, 'mr');
    expect(find.text('स्वयंसेवी संस्था पोर्टल'), findsOneWidget);
    expect(find.text('दावे (Claims)'), findsOneWidget);
    expect(find.text('वाटप'), findsOneWidget);
    expect(find.text('पडताळणी'), findsOneWidget);

    // Tap translate icon again to switch to Hindi
    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();

    await tester.tap(find.text('हिंदी (Hindi)'));
    await tester.pumpAndSettle();

    // Verify locale switched to Hindi
    expect(localeProvider.locale.languageCode, 'hi');
    expect(find.text('एनजीओ पोर्टल'), findsOneWidget);
    expect(find.text('वितरण'), findsOneWidget);
    expect(find.text('सत्यापन'), findsOneWidget);
  });
}
