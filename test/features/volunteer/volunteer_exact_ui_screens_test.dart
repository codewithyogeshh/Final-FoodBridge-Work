import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:foodbridge/core/localization/locale_provider.dart';
import 'package:foodbridge/core/theme/app_theme.dart';
import 'package:foodbridge/core/theme/theme_provider.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';
import 'package:foodbridge/features/notifications/presentation/notification_provider.dart';
import 'package:foodbridge/features/volunteer/presentation/volunteer_get_started_screen.dart';
import 'package:foodbridge/features/volunteer/presentation/volunteer_dashboard_screen.dart';
import 'package:foodbridge/features/volunteer/presentation/volunteer_available_tasks_screen.dart';
import 'package:foodbridge/features/volunteer/presentation/volunteer_task_tracking_screen.dart';
import 'package:foodbridge/features/volunteer/presentation/volunteer_activity_screen.dart';
import 'package:foodbridge/features/volunteer/presentation/volunteer_impact_screen.dart';
import 'package:foodbridge/features/volunteer/presentation/volunteer_profile_screen.dart';
import 'package:foodbridge/features/volunteer/presentation/volunteer_rewards_screen.dart';

Widget createVolunteerTestableWidget(Widget child) {
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
  group('Volunteer Exact UI Screens Tests (Reference Image)', () {
    testWidgets('Screen 1: VolunteerGetStartedScreen renders Be a Volunteer and Get Started', (tester) async {
      await tester.pumpWidget(createVolunteerTestableWidget(const VolunteerGetStartedScreen()));
      expect(find.text('Be a Volunteer'), findsOneWidget);
      expect(find.text('Together we can fight hunger!'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Screen 2: VolunteerDashboardScreen renders greeting, 3 stats, and quick actions', (tester) async {
      await tester.pumpWidget(createVolunteerTestableWidget(const VolunteerDashboardScreen()));
      expect(find.text('Hello Volunteer 👋'), findsOneWidget);
      expect(find.text('Make a difference today!'), findsOneWidget);
      expect(find.text('Tasks Done'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('Next Task'), findsOneWidget);
      expect(find.text('Food Pickup'), findsWidgets);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Upcoming Tasks'), findsOneWidget);
    });

    testWidgets('Screen 3: VolunteerAvailableTasksScreen renders filter chips and tasks', (tester) async {
      await tester.pumpWidget(createVolunteerTestableWidget(const VolunteerAvailableTasksScreen()));
      expect(find.text('Available Tasks'), findsOneWidget);
      expect(find.text('All (12)'), findsOneWidget);
      expect(find.text('Pickup (6)'), findsOneWidget);
      expect(find.text('Delivery (6)'), findsOneWidget);
      expect(find.text('Accept'), findsWidgets);
    });

    testWidgets('Screen 4: VolunteerTaskTrackingScreen renders top card and Mark as Completed button', (tester) async {
      await tester.pumpWidget(createVolunteerTestableWidget(const VolunteerTaskTrackingScreen()));
      await tester.pump();
      expect(find.text('Volunteer Dispatch (थेट कूरियर)'), findsOneWidget);
      expect(find.text('Live GPS'), findsOneWidget);
      expect(find.textContaining('Pick up from'), findsOneWidget);
      expect(find.textContaining('Arrived at Pickup'), findsOneWidget);
    });

    testWidgets('Screen 5: VolunteerActivityScreen renders timeline and filter tabs', (tester) async {
      await tester.pumpWidget(createVolunteerTestableWidget(const VolunteerActivityScreen()));
      expect(find.text('My Activity'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Donations'), findsOneWidget);
      expect(find.text('Deliveries'), findsOneWidget);
      expect(find.text('Food Pickup Completed'), findsOneWidget);
      expect(find.text('Delivery Completed'), findsOneWidget);
      expect(find.text('+50 pts'), findsWidgets);
    });

    testWidgets('Screen 6: VolunteerImpactScreen renders impact metrics and thank you banner', (tester) async {
      await tester.pumpWidget(createVolunteerTestableWidget(const VolunteerImpactScreen()));
      expect(find.text('Your Impact'), findsOneWidget);
      expect(find.text('Together we made a difference!'), findsOneWidget);
      expect(find.text('245'), findsOneWidget);
      expect(find.text('Meals Saved'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('People Helped'), findsOneWidget);
      expect(find.text('25 kg'), findsOneWidget);
      expect(find.text('Food Saved'), findsOneWidget);
      expect(find.text('Your Effort Matters 💚'), findsOneWidget);
    });

    testWidgets('Screen 7: VolunteerProfileScreen renders profile header, stats, and menu options', (tester) async {
      await tester.pumpWidget(createVolunteerTestableWidget(const VolunteerProfileScreen()));
      expect(find.text('Profile'), findsWidgets);
      expect(find.text('FoodBridge Volunteer'), findsOneWidget);
      expect(find.text('Top Volunteer'), findsOneWidget);
      expect(find.text('My Activity'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Rewards & Milestones'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('About FoodBridge'), findsOneWidget);
    });

    testWidgets('Screen 8: VolunteerRewardsScreen renders golden trophy, 100 Hours Club, and badges', (tester) async {
      await tester.pumpWidget(createVolunteerTestableWidget(const VolunteerRewardsScreen()));
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Keep Helping, Keep Growing!'), findsOneWidget);
      expect(find.text('100 Hours Club'), findsOneWidget);
      expect(find.text('72 / 100 h'), findsOneWidget);
      expect(find.text('Your Badges'), findsOneWidget);
      expect(find.text('4 Earned'), findsOneWidget);
      expect(find.text('Volunteer Today...'), findsOneWidget);
      expect(find.text('Build a Hunger-Free Tomorrow'), findsOneWidget);
    });
  });
}
