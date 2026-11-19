import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';
import 'package:foodbridge/features/authentication/data/auth_service.dart';
import 'package:foodbridge/features/authentication/domain/models/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminProvider User Sync & Avatar Tests', () {
    late AdminProvider adminProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      adminProvider = AdminProvider();
    });

    test('ManagedUser model correctly stores and copies avatarUrl and phone', () {
      final user = ManagedUser(
        id: 'usr-test-1',
        fullName: 'Test User',
        email: 'test@foodbridge.org',
        role: UserRole.volunteer,
        avatarUrl: 'https://example.com/avatar.jpg',
        phone: '+91 99999 88888',
        createdAt: DateTime.now(),
      );

      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.phone, '+91 99999 88888');

      final updated = user.copyWith(
        fullName: 'Updated Name',
        avatarUrl: 'data:image/jpeg;base64,samplebase64',
      );

      expect(updated.fullName, 'Updated Name');
      expect(updated.avatarUrl, 'data:image/jpeg;base64,samplebase64');
      expect(updated.phone, '+91 99999 88888');
    });

    test('syncUsersWithAuth updates user names and avatars from AuthService', () async {
      final auth = AuthService();
      final targetUser = AppUser(
        id: 'usr-vol-303',
        email: 'volunteer@foodbridge.org',
        fullName: 'Rohit Kulkarni (Updated Leader)',
        phone: '+91 97654 99887',
        role: UserRole.volunteer,
        avatarUrl: 'https://example.com/rohit_photo.png',
        createdAt: DateTime.now(),
      );

      await auth.updateUser(targetUser);
      await adminProvider.syncUsersWithAuth();

      final managed = adminProvider.managedUsers.firstWhere(
        (u) => u.email == 'volunteer@foodbridge.org',
      );

      expect(managed.fullName, 'Rohit Kulkarni (Updated Leader)');
      expect(managed.avatarUrl, 'https://example.com/rohit_photo.png');
    });

    test('Suspension state is preserved when syncUsersWithAuth runs', () async {
      final targetUser = adminProvider.managedUsers.firstWhere((u) => !u.isSuspended);
      await adminProvider.suspendUser(
        userId: targetUser.id,
        reason: 'Testing suspension persistence during sync',
        adminId: 'admin-001',
      );

      await adminProvider.syncUsersWithAuth();

      final syncedUser = adminProvider.managedUsers.firstWhere((u) => u.id == targetUser.id);
      expect(syncedUser.isSuspended, isTrue);
      expect(syncedUser.suspensionReason, 'Testing suspension persistence during sync');
    });
  });
}
