import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/authentication/data/auth_service.dart';
import 'package:foodbridge/features/authentication/data/session_storage_service.dart';
import 'package:foodbridge/features/authentication/domain/models/app_user.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';

void main() {
  group('AuthProvider Tests - SDLC Phase 6 Authentication & Role Management', () {
    late AuthService authService;
    late SessionStorageService sessionStorage;
    late AuthProvider authProvider;

    setUp(() {
      sessionStorage = SessionStorageService(useInMemoryOnly: true);
      authService = AuthService(sessionStorage: sessionStorage);
      authProvider = AuthProvider(authService: authService);
    });

    test('Initial auth state has default mock donor user in demo mode', () {
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentRole, UserRole.donor);
      expect(authProvider.user?.email, 'donor@foodbridge.org');
    });

    test('switchRole updates current user role and metadata', () {
      authProvider.switchRole(UserRole.ngo);
      expect(authProvider.currentRole, UserRole.ngo);
      expect(authProvider.user?.email, 'ngo@foodbridge.org');
      expect(authProvider.isNgoVerified, isTrue);

      authProvider.switchRole(UserRole.volunteer);
      expect(authProvider.currentRole, UserRole.volunteer);
      expect(authProvider.user?.email, 'volunteer@foodbridge.org');

      authProvider.switchRole(UserRole.admin);
      expect(authProvider.currentRole, UserRole.admin);
      expect(authProvider.user?.email, 'admin@foodbridge.org');
    });

    test('Sign in with valid demo credentials succeeds', () async {
      final success = await authProvider.login(
        email: 'volunteer@foodbridge.org',
        password: 'Password123!',
        requestedRole: UserRole.volunteer,
      );

      expect(success, isTrue);
      expect(authProvider.currentRole, UserRole.volunteer);
      expect(authProvider.user?.fullName, 'Rohit Kulkarni');
      expect(authProvider.isAuthenticated, isTrue);
    });

    test('Sign in with incorrect password is rejected with helpful error', () async {
      final success = await authProvider.login(
        email: 'donor@foodbridge.org',
        password: 'WrongPassword999!',
      );

      expect(success, isFalse);
      expect(authProvider.errorMessage, anyOf(contains('Incorrect password'), contains('पासवर्ड चुकीचा आहे')));
    });

    test('Sign in with unknown email is rejected', () async {
      final success = await authProvider.login(
        email: 'unregistered_random_user@domain.com',
        password: 'Password123!',
      );

      expect(success, isFalse);
      expect(authProvider.errorMessage, anyOf(contains('does not exist'), contains('खाते सापडले नाही')));
    });

    test('Sign out clears user session and persistent storage', () async {
      await authProvider.logout();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);

      final savedSession = await sessionStorage.getUserSession();
      expect(savedSession, isNull);
    });

    test('Valid Donor registration creates complete profile', () async {
      final success = await authProvider.register(
        email: 'new_donor@cafe.com',
        password: 'SecurePassword123!',
        fullName: 'Anita Patil',
        role: UserRole.donor,
        phone: '+91 91234 56789',
        organizationName: 'Anita Bakes & Cafe',
        donorCategory: 'Restaurant / Cafe',
        address: 'FC Road, Pune',
        serviceArea: 'Shivajinagar, Pune',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.fullName, 'Anita Patil');
      expect(authProvider.user?.donorCategory, 'Restaurant / Cafe');
      expect(authProvider.user?.role, UserRole.donor);
    });

    test('Valid NGO registration sets verification status to pending', () async {
      final success = await authProvider.register(
        email: 'contact@hopecharity.org',
        password: 'SecurePassword123!',
        fullName: 'Dr. Alok Verma',
        role: UserRole.ngo,
        organizationName: 'Hope Foundation Shelter',
        darpanId: 'MH/2026/0099881',
        contactPerson: 'Dr. Alok Verma',
        phone: '+91 98888 11223',
        serviceArea: 'Swargate, Pune',
        verificationDocumentUrl: 'docs/hope_charity_80g.pdf',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.role, UserRole.ngo);
      expect(authProvider.user?.ngoVerificationStatus, NgoVerificationStatus.pending);
      expect(authProvider.user?.organizationName, 'Hope Foundation Shelter');
      expect(authProvider.isNgoVerified, isFalse); // Unapproved until admin reviews
    });

    test('Valid Volunteer registration records schedule and transport', () async {
      final success = await authProvider.register(
        email: 'rider_samir@foodbridge.org',
        password: 'SecurePassword123!',
        fullName: 'Samir Shaikh',
        role: UserRole.volunteer,
        phone: '+91 97777 44332',
        serviceArea: 'Kothrud, Pune',
        availability: 'Weekends Only',
        transportType: 'Two-Wheeler / Scooter',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.role, UserRole.volunteer);
      expect(authProvider.user?.transportType, 'Two-Wheeler / Scooter');
      expect(authProvider.user?.availability, 'Weekends Only');
    });

    test('Admin registration through public channel is strictly prohibited', () async {
      final success = await authProvider.register(
        email: 'hacker_admin@domain.com',
        password: 'SecurePassword123!',
        fullName: 'Fake Admin',
        role: UserRole.admin,
      );

      expect(success, isFalse);
      expect(authProvider.errorMessage, contains('Administrator accounts cannot be created'));
    });

    test('Duplicate email registration is rejected', () async {
      final success = await authProvider.register(
        email: 'donor@foodbridge.org', // Already registered
        password: 'Password123!',
        fullName: 'Imposter Donor',
        role: UserRole.donor,
      );

      expect(success, isFalse);
      expect(authProvider.errorMessage, anyOf(contains('already exists'), contains('आधीच खाते तयार केलेले आहे')));
    });

    test('Invalid registration with short password (< 8 chars) is rejected', () async {
      final success = await authProvider.register(
        email: 'valid_email@test.com',
        password: '123', // Too short
        fullName: 'Short Pwd User',
        role: UserRole.donor,
      );

      expect(success, isFalse);
      expect(authProvider.errorMessage, anyOf(contains('at least 8 characters'), contains('किमान १२ अक्षरांचा'), contains('किमान')));
    });

    test('Invalid registration with malformed email is rejected', () async {
      final success = await authProvider.register(
        email: 'notanemail',
        password: 'SecurePassword123!',
        fullName: 'Malformed Email User',
        role: UserRole.donor,
      );

      expect(success, isFalse);
      expect(authProvider.errorMessage, anyOf(contains('valid email'), contains('अचूक ईमेल')));
    });

    test('Password reset request flow and update', () async {
      // 1. Request reset link for existing user
      final emailSent = await authProvider.sendPasswordResetEmail('donor@foodbridge.org');
      expect(emailSent, isTrue);

      // 2. Request reset link for non-existent user fails
      final emailSentFail = await authProvider.sendPasswordResetEmail('nonexistent@foodbridge.org');
      expect(emailSentFail, isFalse);
      expect(authProvider.errorMessage, anyOf(contains('No account found'), contains('खाते सापडले नाही')));

      // 3. Reset password with short password fails
      final shortReset = await authProvider.resetPassword(
        email: 'donor@foodbridge.org',
        newPassword: 'short',
      );
      expect(shortReset, isFalse);
      expect(authProvider.errorMessage, anyOf(contains('at least 8 characters'), contains('किमान १२ अक्षरांचा'), contains('किमान')));

      // 4. Reset password with valid password succeeds
      final validReset = await authProvider.resetPassword(
        email: 'donor@foodbridge.org',
        newPassword: 'NewBrandPassword2026!',
      );
      expect(validReset, isTrue);

      // 5. Sign in with the new password succeeds
      final loginWithNewPwd = await authProvider.login(
        email: 'donor@foodbridge.org',
        password: 'NewBrandPassword2026!',
      );
      expect(loginWithNewPwd, isTrue);
    });

    test('Session persistence saves and restores active profile across reboots', () async {
      final testUser = AppUser(
        id: 'usr-persisted-777',
        email: 'persisted@test.com',
        fullName: 'Persisted Tester',
        role: UserRole.volunteer,
        createdAt: DateTime.now(),
      );

      await sessionStorage.saveUserSession(testUser);
      final restoredUser = await sessionStorage.getUserSession();

      expect(restoredUser, isNotNull);
      expect(restoredUser?.id, 'usr-persisted-777');
      expect(restoredUser?.email, 'persisted@test.com');
      expect(restoredUser?.role, UserRole.volunteer);

      // Clear session
      await sessionStorage.clearUserSession();
      final clearedUser = await sessionStorage.getUserSession();
      expect(clearedUser, isNull);
    });
  });
}
