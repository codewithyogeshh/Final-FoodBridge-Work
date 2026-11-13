import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/fb_appearance_selector.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.translate, size: 18, color: AppColors.primaryGreen),
            label: Text(
              localeProvider.shortName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            onPressed: () => showLanguageBottomSheet(context),
          ),
          IconButton(
            icon: Icon(themeProvider.appearanceIcon, color: AppColors.primaryGreen),
            tooltip: tr.appearance,
            onPressed: () => showAppearanceBottomSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                tr.get('welcome'),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                tr.get('welcome_sub'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedGrey,
                    ),
              ),
              const SizedBox(height: 32),
              Text(
                localeProvider.locale.languageCode == 'mr'
                    ? 'सहभागाचा मार्ग निवडा:'
                    : localeProvider.locale.languageCode == 'hi'
                        ? 'अपनी भागीदारी का प्रकार चुनें:'
                        : 'Choose how you want to participate:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: tr.get('onboarding_role_donor'),
                subtitle: tr.get('donate_food_sub'),
                icon: Icons.restaurant,
                accentColor: AppColors.primaryGreen,
                onTap: () => context.push('/register?role=donor'),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                title: tr.get('onboarding_role_ngo'),
                subtitle: 'Verified charities, food banks & shelter homes',
                icon: Icons.volunteer_activism,
                accentColor: AppColors.orange,
                onTap: () => context.push('/register?role=ngo'),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                title: tr.get('onboarding_role_volunteer'),
                subtitle: 'Deliver & coordinate hyper-local rescue dispatches',
                icon: Icons.two_wheeler,
                accentColor: AppColors.deepGreen,
                onTap: () => context.push('/register?role=volunteer'),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localeProvider.locale.languageCode == 'mr'
                        ? 'आधीच खाते आहे? '
                        : localeProvider.locale.languageCode == 'hi'
                            ? 'क्या आपका पहले से खाता है? '
                            : 'Already have an account? ',
                    style: const TextStyle(color: AppColors.mutedGrey),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/login'),
                    child: Text(
                      tr.signIn,
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      color: isDark ? AppColors.cardDark : AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedGrey,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.mutedGrey),
            ],
          ),
        ),
      ),
    );
  }
}
