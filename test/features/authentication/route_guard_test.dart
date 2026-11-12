import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/core/router/route_guard.dart';
import 'package:foodbridge/features/authentication/domain/models/app_user.dart';

void main() {
  group('RouteGuard Tests', () {
    test('Public routes allow unauthenticated visitors', () {
      expect(
        RouteGuard.evaluate(
          location: '/',
          isAuthenticated: false,
          userRole: null,
        ),
        isNull,
      );

      expect(
        RouteGuard.evaluate(
          location: '/onboarding',
          isAuthenticated: false,
          userRole: null,
        ),
        isNull,
      );

      expect(
        RouteGuard.evaluate(
          location: '/login',
          isAuthenticated: false,
          userRole: null,
        ),
        isNull,
      );

      expect(
        RouteGuard.evaluate(
          location: '/register',
          isAuthenticated: false,
          userRole: null,
        ),
        isNull,
      );

      expect(
        RouteGuard.evaluate(
          location: '/forgot-password',
          isAuthenticated: false,
          userRole: null,
        ),
        isNull,
      );
    });

    test('Unauthenticated user accessing protected dashboard is redirected to /login', () {
      expect(
        RouteGuard.evaluate(
          location: '/donor',
          isAuthenticated: false,
          userRole: null,
        ),
        equals('/login'),
      );

      expect(
        RouteGuard.evaluate(
          location: '/ngo',
          isAuthenticated: false,
          userRole: null,
        ),
        equals('/login'),
      );

      expect(
        RouteGuard.evaluate(
          location: '/volunteer',
          isAuthenticated: false,
          userRole: null,
        ),
        equals('/login'),
      );

      expect(
        RouteGuard.evaluate(
          location: '/admin',
          isAuthenticated: false,
          userRole: null,
        ),
        equals('/login'),
      );
    });

    test('Role boundary: Non-admin accessing /admin is redirected to their own dashboard', () {
      // Donor trying to access admin
      expect(
        RouteGuard.evaluate(
          location: '/admin',
          isAuthenticated: true,
          userRole: UserRole.donor,
        ),
        equals('/donor'),
      );

      // Volunteer trying to access admin
      expect(
        RouteGuard.evaluate(
          location: '/admin',
          isAuthenticated: true,
          userRole: UserRole.volunteer,
        ),
        equals('/volunteer'),
      );

      // NGO trying to access admin
      expect(
        RouteGuard.evaluate(
          location: '/admin',
          isAuthenticated: true,
          userRole: UserRole.ngo,
        ),
        equals('/ngo'),
      );
    });

    test('Authorized roles are permitted on their respective screens', () {
      // Admin on admin console
      expect(
        RouteGuard.evaluate(
          location: '/admin',
          isAuthenticated: true,
          userRole: UserRole.admin,
        ),
        isNull,
      );

      // Donor on donor dashboard
      expect(
        RouteGuard.evaluate(
          location: '/donor',
          isAuthenticated: true,
          userRole: UserRole.donor,
        ),
        isNull,
      );

      // NGO on NGO portal
      expect(
        RouteGuard.evaluate(
          location: '/ngo',
          isAuthenticated: true,
          userRole: UserRole.ngo,
        ),
        isNull,
      );

      // Volunteer on volunteer dispatch
      expect(
        RouteGuard.evaluate(
          location: '/volunteer',
          isAuthenticated: true,
          userRole: UserRole.volunteer,
        ),
        isNull,
      );
    });
  });
}

