import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../localization/locale_provider.dart';
import '../theme/app_colors.dart';

/// Shows a dialog asking the user if they want to exit FoodBridge.
/// If user confirms, calls [SystemNavigator.pop] to gracefully exit on Android.
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  String langCode = 'en';
  try {
    langCode = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
  } catch (_) {
    langCode = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
  }
  final isMr = langCode == 'mr';
  final isHi = langCode == 'hi';

  final title = isMr
      ? 'FoodBridge मधून बाहेर पडायचे?'
      : isHi
          ? 'FoodBridge से बाहर निकलना चाहते हैं?'
          : 'Leave FoodBridge?';

  final message = isMr
      ? 'तुम्हाला खरंच FoodBridge ॲपमधून बाहेर पडायचे आहे का?'
      : isHi
          ? 'क्या आप वास्तव में FoodBridge ऐप बंद करना चाहते हैं?'
          : 'Are you sure you want to exit the FoodBridge app?';

  final cancelText = isMr ? 'नाही' : isHi ? 'नहीं' : 'Stay';
  final exitText = isMr ? 'होय, बाहेर पडा' : isHi ? 'हाँ, बाहर निकलें' : 'Yes, Exit';

  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.exit_to_app,
              color: AppColors.errorRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: isDark ? Colors.white : AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : AppColors.charcoal,
          height: 1.4,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(
            cancelText,
            style: const TextStyle(
              color: AppColors.mutedGrey,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.errorRed,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            exitText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    ),
  );

  if (shouldExit == true) {
    await SystemNavigator.pop();
    return true;
  }
  return false;
}

/// A wrapper widget around root screens (Dashboards) to intercept
/// Android system back button gestures and show the confirmation prompt.
class FoodBridgeExitScope extends StatelessWidget {
  final Widget child;

  const FoodBridgeExitScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await showExitConfirmationDialog(context);
      },
      child: child,
    );
  }
}
