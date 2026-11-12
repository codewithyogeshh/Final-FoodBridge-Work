import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/authentication/domain/models/app_user.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
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

    test('Sign in with demo credentials succeeds', () async {
      final success = await authProvider.login(
        email: 'volunteer@foodbridge.org',
        password: 'Password123!',
        requestedRole: UserRole.volunteer,
      );

      expect(success, isTrue);
      expect(authProvider.currentRole, UserRole.volunteer);
      expect(authProvider.user?.fullName, 'Rohit Kulkarni');
    });

    test('Sign out clears user session', () async {
      await authProvider.logout();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);
    });

    test('Register creates and signs in a new profile', () async {
      final success = await authProvider.register(
        email: 'test_new_donor@example.com',
        password: 'Password123!',
        fullName: 'Anita Patil',
        role: UserRole.donor,
        phone: '+91 91234 56789',
      );

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.fullName, 'Anita Patil');
      expect(authProvider.currentRole, UserRole.donor);
    });
  });
}
