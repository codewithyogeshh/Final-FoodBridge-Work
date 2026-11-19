import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/core/localization/locale_provider.dart';
import 'package:foodbridge/core/theme/app_theme.dart';
import 'package:foodbridge/core/theme/theme_provider.dart';
import 'package:foodbridge/core/widgets/donation_image_widget.dart';
import 'package:foodbridge/features/admin/presentation/admin_provider.dart';
import 'package:foodbridge/features/authentication/presentation/auth_provider.dart';
import 'package:foodbridge/features/donations/domain/models/donation.dart';
import 'package:foodbridge/features/donations/presentation/donation_detail_screen.dart';
import 'package:foodbridge/features/donations/presentation/donation_provider.dart';
import 'package:foodbridge/features/donor/presentation/donate_clothes_screen.dart';
import 'package:foodbridge/features/notifications/presentation/notification_provider.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp(Widget child, {DonationProvider? donationProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider.value(value: donationProvider ?? DonationProvider()),
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Clothing Donation Photo & Banner System Tests', () {
    testWidgets('DonationImageWidget displays correct fallback when image URL is null or empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                DonationImageWidget(
                  imageUrl: null,
                  isFood: false,
                  width: 50,
                  height: 50,
                ),
                DonationImageWidget(
                  imageUrl: '',
                  isFood: true,
                  width: 50,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify clothes fallback icon appears
      expect(find.byIcon(Icons.checkroom_rounded), findsOneWidget);
      // Verify food fallback icon appears
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
    });

    testWidgets('DonateClothesScreen renders camera, gallery, and preset photo options',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(const DonateClothesScreen()));
      await tester.pumpAndSettle();

      // Check for camera and gallery action chips
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);

      // Check for presets
      expect(find.text('Jackets'), findsOneWidget);
      expect(find.text('Folded'), findsOneWidget);
      expect(find.text('Kids Wear'), findsWidgets);

      // Tap on Folded preset
      await tester.tap(find.text('Folded'));
      await tester.pumpAndSettle();

      // Check that form elements are present
      expect(find.text('Clothing Category *'), findsOneWidget);
      expect(find.text('Collection Deadline *'), findsOneWidget);
      expect(find.text('Publish Clothing Donation'), findsOneWidget);
    });

    testWidgets('DonationDetailScreen renders prominent Hero Donation Banner with photo',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final provider = DonationProvider();
      final sampleDonation = Donation(
        id: 'cloth-test-banner-1',
        donorId: 'usr-donor-101',
        donorName: 'Rahul Sharma',
        donorPhone: '+91 98200 12345',
        title: 'Warm Winter Blankets and Jackets',
        description: 'Clean wool blankets and warm jackets in great shape.',
        quantity: 25,
        unit: 'pieces',
        type: DonationType.clothing,
        status: DonationStatus.available,
        pickupAddress: 'Shivajinagar, Pune',
        city: 'Pune',
        createdAt: DateTime.now(),
        pickupDeadline: DateTime.now().add(const Duration(days: 3)),
        clothingCategory: 'Winter Wear',
        imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600',
        pickupOtp: '1234',
        deliveryOtp: '5678',
      );

      await provider.createDonation(sampleDonation);

      await tester.pumpWidget(
        _buildTestApp(
          const DonationDetailScreen(donationId: 'cloth-test-banner-1'),
          donationProvider: provider,
        ),
      );
      await tester.pumpAndSettle();

      // Verify the Hero Donation Banner exists
      expect(find.byType(DonationImageWidget), findsOneWidget);
      expect(find.text('Winter Wear'), findsWidgets);
      expect(find.text('Tap to enlarge'), findsOneWidget);
      expect(find.text('Warm Winter Blankets and Jackets'), findsOneWidget);
    });
  });
}
