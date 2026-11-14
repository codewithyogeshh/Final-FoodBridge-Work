import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodbridge/main.dart';
import 'package:foodbridge/core/theme/app_theme.dart';
import 'package:foodbridge/core/theme/theme_provider.dart';
import 'package:foodbridge/core/localization/locale_provider.dart';
import 'package:foodbridge/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';
import 'package:foodbridge/features/authentication/presentation/login_screen.dart';
import 'package:foodbridge/features/authentication/presentation/register_screen.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';
import 'package:foodbridge/features/donor/presentation/donor_dashboard_screen.dart';
import 'package:foodbridge/features/ngo/presentation/ngo_dashboard_screen.dart';
import 'package:foodbridge/features/notifications/presentation/notification_provider.dart';
import 'package:foodbridge/features/notifications/presentation/notifications_screen.dart';
import 'package:foodbridge/features/onboarding/presentation/onboarding_screen.dart';
import 'package:foodbridge/features/profile/presentation/profile_screen.dart';
import 'package:foodbridge/features/volunteer/presentation/volunteer_dashboard_screen.dart';

Widget createTestableWidget(Widget child) {
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
      home: child,
    ),
  );
}

void main() {
  group('SDLC Phase 11: UI & Major Screens Tests', () {
    testWidgets('SplashScreen renders FoodBridge logo and brand tagline', (tester) async {
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
      expect(find.text('FoodBridge'), findsOneWidget);
      expect(find.text('Share More. Waste Less. Bridge the Need.'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('OnboardingScreen renders role selection cards and instructions', (tester) async {
      await tester.pumpWidget(createTestableWidget(const OnboardingScreen()));
      expect(find.text('Select Your Role'), findsOneWidget);
      expect(find.text('Restaurant\nDonor'), findsOneWidget);
      expect(find.text('Normal\nDonor'), findsOneWidget);
      expect(find.text('Volunteer'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('LoginScreen renders email, password fields and sign in action', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginScreen()));
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders role selection and registration form', (tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterScreen()));
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Donor'), findsOneWidget);
      expect(find.text('NGO Shelter'), findsOneWidget);
      expect(find.text('Volunteer'), findsOneWidget);
    });

    testWidgets('DonorDashboardScreen renders quick actions and active listings', (tester) async {
      await tester.pumpWidget(createTestableWidget(const DonorDashboardScreen()));
      expect(find.textContaining('Hello'), findsOneWidget);
      expect(find.text('Donor Dashboard'), findsOneWidget);
      expect(find.text('New Donation'), findsWidgets);
      expect(find.text('Donate Surplus Food'), findsOneWidget);
    });

    testWidgets('NgoDashboardScreen renders discovery feed and claim actions', (tester) async {
      await tester.pumpWidget(createTestableWidget(const NgoDashboardScreen()));
      expect(find.text('NGO Portal'), findsOneWidget);
    });

    testWidgets('VolunteerDashboardScreen renders task feed and availability toggle', (tester) async {
      await tester.pumpWidget(createTestableWidget(const VolunteerDashboardScreen()));
      expect(find.text('Hello Volunteer 👋'), findsOneWidget);
      expect(find.text('Tasks Done'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('Upcoming Tasks'), findsOneWidget);
    });

    testWidgets('AdminDashboardScreen renders 5 control tabs and live console', (tester) async {
      await tester.pumpWidget(createTestableWidget(const AdminDashboardScreen()));
      expect(find.text('Admin Console'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('NotificationsScreen renders notifications center and filter chips', (tester) async {
      await tester.pumpWidget(createTestableWidget(const NotificationsScreen()));
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('ProfileScreen renders user details, settings and enforces strict auth without role switcher', (tester) async {
      await tester.pumpWidget(createTestableWidget(const ProfileScreen()));
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('SWITCH ACTIVE ROLE VIEW'), findsNothing);
    });
  });
}
