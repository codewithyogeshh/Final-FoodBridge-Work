import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodbridge/core/theme/app_colors.dart';
import 'package:foodbridge/core/theme/app_theme.dart';
import 'package:foodbridge/core/theme/theme_provider.dart';
import 'package:foodbridge/core/localization/locale_provider.dart';
import 'package:foodbridge/core/widgets/fb_button.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';
import 'package:foodbridge/features/authentication/presentation/login_screen.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';
import 'package:foodbridge/features/notifications/presentation/notification_provider.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';

double calculateLuminance(Color color) {
  double channel(double c) {
    c = c / 255.0;
    return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(color.red.toDouble());
  final g = channel(color.green.toDouble());
  final b = channel(color.blue.toDouble());

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrastRatio(Color foreground, Color background) {
  final l1 = calculateLuminance(foreground);
  final l2 = calculateLuminance(background);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

Widget createTestableApp(Widget child, {TextScaler? textScaler}) {
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
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler ?? TextScaler.noScaling),
        child: child,
      ),
    ),
  );
}

void main() {
  group('SDLC Phase 11: Accessibility & WCAG Contrast Tests', () {
    test('WCAG 2.1 Contrast ratios: Key brand colors meet AA and AAA thresholds', () {
      // 1. Primary Green (#218C5A) vs White (#FFFFFF) - AA Large/Bold Text threshold is 3.0:1 (Used on bold CTAs)
      final greenOnWhite = contrastRatio(
        AppColors.primaryGreen,
        AppColors.white,
      );
      expect(greenOnWhite, greaterThanOrEqualTo(3.0));

      // 2. Deep Green (#145A3A) vs White (#FFFFFF) - AAA Normal Text threshold is 7.0:1 (Used on body labels)
      final deepGreenOnWhite = contrastRatio(
        AppColors.deepGreen,
        AppColors.white,
      );
      expect(deepGreenOnWhite, greaterThanOrEqualTo(7.0));

      // 3. Charcoal (#263238) vs Warm Cream (#FFF8ED) - AAA threshold is 7.0:1
      final charcoalOnCream = contrastRatio(
        AppColors.charcoal,
        AppColors.warmCream,
      );
      expect(charcoalOnCream, greaterThanOrEqualTo(7.0));

      // 4. Error Red (#C83D3D) vs White (#FFFFFF) - AA threshold is 4.5:1
      final redOnWhite = contrastRatio(AppColors.errorRed, AppColors.white);
      expect(redOnWhite, greaterThanOrEqualTo(4.5));
    });

    testWidgets(
      'Touch target size: FBButton conforms to minimum 48x48 dp touch target',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FBButton(label: 'Confirm Pickup', onPressed: () {}),
            ),
          ),
        );

        final buttonFinder = find.byType(FBButton);
        final size = tester.getSize(buttonFinder);

        expect(size.height, greaterThanOrEqualTo(48.0));
        expect(size.width, greaterThanOrEqualTo(48.0));
      },
    );

    testWidgets(
      'Font Scaling: 1.5x scaling does not cause RenderFlex overflows on LoginScreen',
      (tester) async {
        await tester.pumpWidget(
          createTestableApp(
            const LoginScreen(),
            textScaler: const TextScaler.linear(1.5),
          ),
        );

        expect(find.text('Welcome Back'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Font Scaling: 2.0x high-scaling renders cleanly on LoginScreen',
      (tester) async {
        await tester.pumpWidget(
          createTestableApp(
            const LoginScreen(),
            textScaler: const TextScaler.linear(2.0),
          ),
        );

        expect(find.text('Welcome Back'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Keyboard Focus Traversal: Form fields allow focus navigation',
      (tester) async {
        final emailFocus = FocusNode();
        final passwordFocus = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(
                    focusNode: emailFocus,
                    key: const Key('email_field'),
                  ),
                  TextField(
                    focusNode: passwordFocus,
                    key: const Key('password_field'),
                  ),
                ],
              ),
            ),
          ),
        );

        emailFocus.requestFocus();
        await tester.pump();
        expect(emailFocus.hasFocus, isTrue);

        passwordFocus.requestFocus();
        await tester.pump();
        expect(passwordFocus.hasFocus, isTrue);
        expect(emailFocus.hasFocus, isFalse);
      },
    );
  });
}
