import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodbridge/core/theme/app_theme.dart';
import 'package:foodbridge/core/theme/theme_provider.dart';
import 'package:foodbridge/core/localization/locale_provider.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';
import 'package:foodbridge/features/authentication/presentation/register_screen.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';
import 'package:foodbridge/features/notifications/presentation/notification_provider.dart';

Widget createRegisterTestWidget() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => DonationProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ChangeNotifierProvider(create: (_) => AdminProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: const RegisterScreen(),
    ),
  );
}

void main() {
  group('Register Donor Identity Proof & Account Creation Tests', () {
    testWidgets('RegisterScreen displays Create Account and Donor Identity Proof section', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createRegisterTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.textContaining('दात्याचे ओळखपत्र'), findsOneWidget);
      expect(find.textContaining('Aadhaar / PAN Card'), findsWidgets);
    });

    testWidgets('Tapping Register without uploading Donor ID prompts mandatory error', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createRegisterTestWidget());
      await tester.pumpAndSettle();

      // Enter Contact Person Name
      final nameField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'e.g. Vikram Joshi',
      );
      await tester.enterText(nameField, 'Vikram Joshi');

      // Enter Email
      final emailField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'donor@restaurant.com',
      );
      await tester.enterText(emailField, 'vikram@foodbridge.org');

      // Enter Mobile
      final phoneField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == '+91 98200 12345',
      );
      await tester.enterText(phoneField, '9820012345');

      // Enter Address
      final addressField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Shop 4, Powai Naka, Satara',
      );
      await tester.enterText(addressField, 'Powai Naka, Satara');

      // Enter 12-char Password
      final pwdField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'उदा. FoodBridge@2026',
      );
      await tester.enterText(pwdField, 'FoodBridge@2026');

      // Check Terms checkbox
      final checkbox = find.byType(Checkbox);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Tap Register as Donor button without selecting Identity Proof
      final registerBtn = find.text('Register as Donor');
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pump(const Duration(milliseconds: 300));

      // Should prompt to upload Aadhaar or PAN card
      expect(
        find.textContaining('कृपया दात्याचे ओळखपत्र (Aadhaar किंवा PAN Card) जोडा'),
        findsOneWidget,
      );
    });
  });
}
