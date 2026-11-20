import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env_config.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'features/admin/presentation/admin_provider.dart';
import 'features/authentication/presentation/auth_provider.dart';
import 'features/donations/presentation/donation_provider.dart';
import 'features/notifications/domain/models/app_notification.dart';
import 'features/notifications/presentation/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  if (EnvConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
    } catch (_) {
      // Gracefully continue if network is unreachable or in tests
    }
  }

  final notificationProvider = NotificationProvider(seedInitial: false);
  final donationProvider = DonationProvider();

  // Connect real-time donation events directly to notification dispatch
  DonationProvider.onDonationReceived = (title, body, donationId) {
    notificationProvider.dispatchRealtimeEvent(
      title: title,
      message: body,
      type: NotificationType.newDonation,
      relatedDonationId: donationId,
      actionRoute: donationId != null ? '/donation-detail/$donationId' : null,
    );
  };

  DonationProvider.onNotificationDispatch = (title, body, type, donationId) {
    notificationProvider.dispatchRealtimeEvent(
      title: title,
      message: body,
      type: type,
      relatedDonationId: donationId,
      actionRoute: donationId != null ? '/donation-detail/$donationId' : null,
    );
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: donationProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const FoodBridgeApp(),
    ),
  );
}

class FoodBridgeApp extends StatelessWidget {
  const FoodBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp.router(
      title: EnvConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
      locale: localeProvider.locale,
      supportedLocales: LocaleProvider.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
