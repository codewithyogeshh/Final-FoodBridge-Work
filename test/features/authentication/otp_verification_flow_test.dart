import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodbridge/core/router/route_guard.dart';
import 'package:foodbridge/core/theme/app_theme.dart';
import 'package:foodbridge/core/theme/theme_provider.dart';
import 'package:foodbridge/core/localization/locale_provider.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';
import 'package:foodbridge/features/authentication/data/auth_service.dart';
import 'package:foodbridge/features/authentication/data/session_storage_service.dart';
import 'package:foodbridge/features/authentication/domain/models/app_user.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';
import 'package:foodbridge/features/authentication/presentation/otp_verification_screen.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';
import 'package:foodbridge/features/notifications/presentation/notification_provider.dart';

Widget createOtpTestWidget({
  required String email,
  String? role,
  AuthProvider? authProvider,
  int cooldownSeconds = 0,
  int otpLength = 6,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider.value(value: authProvider ?? AuthProvider()),
      ChangeNotifierProvider(create: (_) => DonationProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ChangeNotifierProvider(create: (_) => AdminProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: OtpVerificationScreen(
        email: email,
        initialRole: role,
        cooldownSeconds: cooldownSeconds,
        otpLength: otpLength,
      ),
    ),
  );
}

void main() {
  group('FoodBridge 6-Digit Email OTP Verification Tests', () {
    late AuthService authService;
    late SessionStorageService sessionStorage;
    late AuthProvider authProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sessionStorage = SessionStorageService(useInMemoryOnly: true);
      authService = AuthService(sessionStorage: sessionStorage);
      await authService.signOut();
      authProvider = AuthProvider(authService: authService);
    });

    test('RouteGuard allows unauthenticated access to /verify-otp', () {
      final redirect = RouteGuard.evaluate(
        location: '/verify-otp',
        isAuthenticated: false,
        userRole: null,
      );
      expect(redirect, isNull);

      final redirectWithQuery = RouteGuard.evaluate(
        location: '/verify-otp?email=test%40example.com&role=donor',
        isAuthenticated: false,
        userRole: null,
      );
      expect(redirectWithQuery, isNull);
    });

    test('AuthService.initiateRegistrationWithOtp dispatches OTP and stores pending signup', () async {
      final success = await authService.initiateRegistrationWithOtp(
        email: 'new_volunteer@pune.org',
        password: 'SecurePassword123!',
        fullName: 'Sameer Joshi',
        role: UserRole.volunteer,
        phone: '+91 98888 77777',
      );

      expect(success, isTrue);
    });

    test('AuthService duplicate email registration is rejected', () async {
      // donor@foodbridge.org is already registered
      expect(
        () => authService.initiateRegistrationWithOtp(
          email: 'donor@foodbridge.org',
          password: 'Password123!',
          fullName: 'Duplicate User',
          role: UserRole.donor,
        ),
        throwsA(predicate((e) =>
            e.toString().contains('already exists') ||
            e.toString().contains('आधीच खाते तयार केलेले आहे'))),
      );
    });

    test('AuthService.verifyEmailOtp verifies valid OTP and activates session', () async {
      const email = 'kavita_donor@freshcafe.in';
      await authService.initiateRegistrationWithOtp(
        email: email,
        password: 'Password123!',
        fullName: 'Kavita Shinde',
        role: UserRole.donor,
        organizationName: 'Fresh Cafe Pune',
        donorCategory: 'Restaurant / Cafe',
      );

      // Verify with standard test OTP '123456'
      final user = await authService.verifyEmailOtp(
        email: email,
        token: '123456',
        role: UserRole.donor,
      );

      expect(user.email, email);
      expect(user.fullName, 'Kavita Shinde');
      expect(user.isEmailVerified, isTrue);
      expect(authService.currentUser?.email, email);
    });

    test('AuthService.verifyEmailOtp rejects invalid OTP code', () async {
      const email = 'rider_test@pune.in';
      await authService.initiateRegistrationWithOtp(
        email: email,
        password: 'Password123!',
        fullName: 'Rider Test',
        role: UserRole.volunteer,
      );

      expect(
        () => authService.verifyEmailOtp(
          email: email,
          token: '999999', // wrong OTP
          role: UserRole.volunteer,
        ),
        throwsA(predicate((e) => e.toString().contains('Invalid or expired'))),
      );
    });

    test('AuthService.verifyEmailOtp rejects incomplete OTP length', () async {
      expect(
        () => authService.verifyEmailOtp(
          email: 'incomplete@test.org',
          token: '123',
        ),
        throwsA(predicate((e) => e.toString().contains('6-digit'))),
      );
    });

    test('AuthService.resendOtp triggers fresh OTP delivery without error', () async {
      await authService.initiateRegistrationWithOtp(
        email: 'resend_user@test.org',
        password: 'Password123!',
        fullName: 'Resend User',
        role: UserRole.donor,
      );

      // Resending should succeed
      await expectLater(
        authService.resendOtp(email: 'resend_user@test.org'),
        completes,
      );
    });

    testWidgets('OtpVerificationScreen renders 6-digit input boxes and cooldown timer', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createOtpTestWidget(
        email: 'verify_me@example.com',
        role: 'donor',
        authProvider: authProvider,
        cooldownSeconds: 60,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Enter Verification Code'), findsOneWidget);
      expect(find.text('verify_me@example.com'), findsOneWidget);
      expect(find.text('Verify OTP'), findsOneWidget);
      expect(find.textContaining('Resend code in'), findsOneWidget);
      expect(find.textContaining('never share this 6-digit code'), findsOneWidget);

      // Verify there are 6 digit text fields
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(6));
    });

    testWidgets('Entering invalid OTP shows inline error message', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await authService.initiateRegistrationWithOtp(
        email: 'wrong_code@example.com',
        password: 'Password123!',
        fullName: 'Wrong Code User',
        role: UserRole.donor,
      );

      await tester.pumpWidget(createOtpTestWidget(
        email: 'wrong_code@example.com',
        role: 'donor',
        authProvider: authProvider,
        cooldownSeconds: 0,
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '9');
      }
      await tester.pumpAndSettle();

      // Tap Verify OTP
      await tester.tap(find.text('Verify OTP'));
      await tester.pumpAndSettle();

      // Check for humanized Marathi/English error
      expect(
        find.byWidgetPredicate((w) =>
            w is Text &&
            (w.data?.contains('पडताळणी कोड') == true ||
                w.data?.contains('Invalid') == true ||
                w.data?.contains('चुकीचा') == true)),
        findsWidgets,
      );
    });

    testWidgets('Entering correct OTP verifies account and shows success message', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const email = 'success_user@example.com';
      await authService.initiateRegistrationWithOtp(
        email: email,
        password: 'Password123!',
        fullName: 'Success User',
        role: UserRole.donor,
      );

      await tester.pumpWidget(createOtpTestWidget(
        email: email,
        role: 'donor',
        authProvider: authProvider,
        cooldownSeconds: 0,
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      const testCode = '123456';
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), testCode[i]);
      }
      await tester.pumpAndSettle();

      // Tap Verify OTP
      await tester.ensureVisible(find.text('Verify OTP'));
      await tester.tap(find.text('Verify OTP'));
      await tester.pumpAndSettle();

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.email, email);
      expect(find.textContaining('Email verified successfully!'), findsWidgets);
    });

    testWidgets('Entering 8-digit OTP verifies account successfully', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const email = 'eight_digit_user@example.com';
      await authService.initiateRegistrationWithOtp(
        email: email,
        password: 'Password123!',
        fullName: 'Eight Digit User',
        role: UserRole.donor,
      );

      await tester.pumpWidget(createOtpTestWidget(
        email: email,
        role: 'donor',
        authProvider: authProvider,
        cooldownSeconds: 0,
        otpLength: 8,
      ));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(8));

      const testCode = '12345678';
      for (int i = 0; i < 8; i++) {
        await tester.enterText(textFields.at(i), testCode[i]);
      }
      await tester.pumpAndSettle();

      // Tap Verify OTP
      await tester.ensureVisible(find.text('Verify OTP'));
      await tester.tap(find.text('Verify OTP'));
      await tester.pumpAndSettle();

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.email, email);
      expect(find.textContaining('Email verified successfully!'), findsWidgets);
    });
  });
}
