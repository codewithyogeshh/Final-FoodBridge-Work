import '../../features/authentication/domain/models/app_user.dart';

class RouteGuard {
  RouteGuard._();

  static const List<String> publicRoutes = [
    '/',
    '/onboarding',
    '/login',
    '/register',
    '/forgot-password',
  ];

  /// Evaluates target route and returns redirect path if unauthorized, or null if allowed
  static String? evaluate({
    required String location,
    required bool isAuthenticated,
    required UserRole? userRole,
  }) {
    final isPublic = publicRoutes.any((route) => location == route || location.startsWith('/register'));

    // 1. Unauthenticated user accessing private route
    if (!isAuthenticated && !isPublic) {
      return '/login';
    }

    // 2. Role-based boundaries for authenticated users
    if (isAuthenticated && userRole != null) {
      // Prevent non-admins from entering admin console
      if (location.startsWith('/admin') && userRole != UserRole.admin) {
        return '/${userRole.name}';
      }

      // Prevent donors from directly accessing volunteer rider mode
      if (location.startsWith('/volunteer') && userRole == UserRole.donor) {
        return '/donor';
      }
    }

    return null;
  }
}

