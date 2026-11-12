import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/authentication/presentation/register_screen.dart';
import '../../features/donor/presentation/donor_dashboard_screen.dart';
import '../../features/donor/presentation/create_donation_screen.dart';
import '../../features/donations/presentation/donation_detail_screen.dart';
import '../../features/ngo/presentation/ngo_dashboard_screen.dart';
import '../../features/volunteer/presentation/volunteer_dashboard_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
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
        path: '/donor',
        builder: (context, state) => const DonorDashboardScreen(),
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
        path: '/volunteer',
        builder: (context, state) => const VolunteerDashboardScreen(),
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
