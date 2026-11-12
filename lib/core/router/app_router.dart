import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/authentication/presentation/register_screen.dart';
import '../../features/authentication/presentation/forgot_password_screen.dart';
import '../../features/authentication/presentation/auth_provider.dart';
import '../../features/donor/presentation/donor_dashboard_screen.dart';
import '../../features/donor/presentation/create_donation_screen.dart';
import '../../features/donor/presentation/my_donations_screen.dart';
import '../../features/donations/presentation/donation_detail_screen.dart';
import '../../features/ngo/presentation/ngo_dashboard_screen.dart';
import '../../features/ngo/presentation/ngo_claims_screen.dart';
import '../../features/ngo/presentation/ngo_verification_screen.dart';
import '../../features/volunteer/presentation/volunteer_dashboard_screen.dart';
import '../../features/volunteer/presentation/volunteer_history_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import 'route_guard.dart';

class AppRouter {
  static GoRouter createRouter([AuthProvider? authProvider]) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (authProvider == null) return null;
        return RouteGuard.evaluate(
          location: state.matchedLocation,
          isAuthenticated: authProvider.isAuthenticated,
          userRole: authProvider.user?.role,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) {
            final role = state.uri.queryParameters['role'];
            return RegisterScreen(initialRole: role);
          },
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/donor',
          builder: (context, state) => const DonorDashboardScreen(),
        ),
        GoRoute(
          path: '/donor/my-donations',
          builder: (context, state) => const MyDonationsScreen(),
        ),
        GoRoute(
          path: '/create-donation',
          builder: (context, state) => const CreateDonationScreen(),
        ),
        GoRoute(
          path: '/donation-detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return DonationDetailScreen(donationId: id);
          },
        ),
        GoRoute(
          path: '/ngo',
          builder: (context, state) => const NgoDashboardScreen(),
        ),
        GoRoute(
          path: '/ngo/my-claims',
          builder: (context, state) => const NgoClaimsScreen(),
        ),
        GoRoute(
          path: '/ngo/verification',
          builder: (context, state) => const NgoVerificationScreen(),
        ),
        GoRoute(
          path: '/volunteer',
          builder: (context, state) => const VolunteerDashboardScreen(),
        ),
        GoRoute(
          path: '/volunteer/history',
          builder: (context, state) => const VolunteerHistoryScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri}'),
        ),
      ),
    );
  }

  static final GoRouter router = createRouter();
}
