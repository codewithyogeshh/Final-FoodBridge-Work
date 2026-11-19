import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';
import 'package:foodbridge/features/profile/presentation/edit_profile_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('EditProfileScreen renders name, phone, and save controls', (tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(
          home: EditProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Full Name (पूर्ण नाव)'), findsOneWidget);
    expect(find.text('Phone Number (मोबाईल नंबर)'), findsOneWidget);
    expect(find.text('Address / Location (पत्ता / शहर)'), findsOneWidget);
    expect(find.text('Save Profile Changes (बदल जतन करा)'), findsOneWidget);
  });

  testWidgets('EditProfileScreen renders cleanly for Volunteer user with Two-Wheeler transport', (tester) async {
    final authProvider = AuthProvider();
    await authProvider.login(
      email: 'volunteer@foodbridge.org',
      password: 'Password123!',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(
          home: EditProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Transport Mode (डिलिव्हरी वाहन प्रकार)'), findsOneWidget);
    expect(find.text('🛵 Two-Wheeler / Scooter (बाईक/स्कूटर)'), findsOneWidget);
  });
}
