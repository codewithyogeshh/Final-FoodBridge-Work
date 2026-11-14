import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/fb_appearance_selector.dart';
import '../../../core/widgets/foodbridge_logo.dart';

/// The official FoodBridge Role Selection Screen (Matching Image 1 Screen 2).
/// Displays a 2x2 grid of roles:
/// - Restaurant Donor
/// - Normal Donor
/// - Volunteer
/// - Admin
/// With interactive selection state and the solid green 'Continue ->' pill button.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _selectedRoleKey = 'normal_donor'; // 'restaurant_donor', 'normal_donor', 'volunteer', 'admin'

  void _onContinue() {
    switch (_selectedRoleKey) {
      case 'restaurant_donor':
        context.push('/login?role=donor&category=restaurant');
        break;
      case 'normal_donor':
        context.push('/login?role=donor&category=individual');
        break;
      case 'volunteer':
        context.push('/volunteer/get-started');
        break;
      case 'admin':
        context.push('/login?role=admin');
        break;
    }
  }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Logo Header
              const Center(
                child: FoodBridgeLogo(
                  size: 64,
                  showTagline: false,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  localeProvider.locale.languageCode == 'mr'
                      ? 'तुमची भूमिका निवडा'
                      : localeProvider.locale.languageCode == 'hi'
                          ? 'अपनी भूमिका चुनें'
                          : 'Select Your Role',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepGreen,
                      ),
                ),
              ),
              const SizedBox(height: 20),

              // 2x2 Grid of Roles - Row 1
              Row(
                children: [
                  Expanded(
                    child: _RoleGridCard(
                      title: localeProvider.locale.languageCode == 'mr'
                          ? 'हॉटेल / रेस्टॉरंट'
                          : localeProvider.locale.languageCode == 'hi'
                              ? 'रेस्टोरेंट डोनर'
                              : 'Restaurant\nDonor',
                      subtitle: localeProvider.locale.languageCode == 'mr'
                          ? 'हॉटेलमधील अन्न दान करा'
                          : localeProvider.locale.languageCode == 'hi'
                              ? 'रेस्टोरेंट से भोजन दान करें'
                              : 'Donate Food from Your Restaurant',
                      icon: Icons.restaurant_menu,
                      isSelected: _selectedRoleKey == 'restaurant_donor',
                      onTap: () => setState(() => _selectedRoleKey = 'restaurant_donor'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _RoleGridCard(
                      title: localeProvider.locale.languageCode == 'mr'
                          ? 'सामान्य दाता'
                          : localeProvider.locale.languageCode == 'hi'
                              ? 'सामान्य डोनर'
                              : 'Normal\nDonor',
                      subtitle: localeProvider.locale.languageCode == 'mr'
                          ? 'घरी बनवलेले अन्न शेअर करा'
                          : localeProvider.locale.languageCode == 'hi'
                              ? 'घर से भोजन साझा करें'
                              : 'Share Food from Home',
                      icon: Icons.card_giftcard,
                      isSelected: _selectedRoleKey == 'normal_donor',
                      onTap: () => setState(() => _selectedRoleKey = 'normal_donor'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2x2 Grid of Roles - Row 2
              Row(
                children: [
                  Expanded(
                    child: _RoleGridCard(
                      title: localeProvider.locale.languageCode == 'mr'
                          ? 'स्वयंसेवक'
                          : localeProvider.locale.languageCode == 'hi'
                              ? 'स्वयंसेवक'
                              : 'Volunteer',
                      subtitle: localeProvider.locale.languageCode == 'mr'
                          ? 'समुदायाची सेवा व मदत'
                          : localeProvider.locale.languageCode == 'hi'
                              ? 'समुदाय की सेवा और सहायता'
                              : 'Serve & Support Our Community',
                      icon: Icons.groups_outlined,
                      isSelected: _selectedRoleKey == 'volunteer',
                      onTap: () => setState(() => _selectedRoleKey = 'volunteer'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _RoleGridCard(
                      title: localeProvider.locale.languageCode == 'mr'
                          ? 'प्रशासक'
                          : localeProvider.locale.languageCode == 'hi'
                              ? 'एडमिन'
                              : 'Admin',
                      subtitle: localeProvider.locale.languageCode == 'mr'
                          ? 'प्लॅटफॉर्म व्यवस्थापन व देखरेख'
                          : localeProvider.locale.languageCode == 'hi'
                              ? 'प्लेटफॉर्म प्रबंधन व निगरानी'
                              : 'Manage & Monitor The Platform',
                      icon: Icons.admin_panel_settings_outlined,
                      isSelected: _selectedRoleKey == 'admin',
                      onTap: () => setState(() => _selectedRoleKey = 'admin'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Solid green Continue button matching design
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localeProvider.locale.languageCode == 'mr'
                            ? 'पुढे जा'
                            : localeProvider.locale.languageCode == 'hi'
                                ? 'आगे बढ़ें'
                                : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Direct link to NGO Shelter Portal
              Center(
                child: TextButton(
                  onPressed: () => context.push('/register?role=ngo'),
                  child: Text(
                    localeProvider.locale.languageCode == 'mr'
                        ? 'नोंदणीकृत NGO आहात का? येथे सामील व्हा →'
                        : localeProvider.locale.languageCode == 'hi'
                            ? 'पंजीकृत एनजीओ हैं? यहाँ शामिल हों →'
                            : 'Are you a verified NGO? Register shelter here →',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleGridCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.primaryGreen.withOpacity(0.18) : const Color(0xFFEAF8F0))
                : (isDark ? AppColors.cardDark : AppColors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              width: isSelected ? 2.2 : 1.2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : (isDark ? Colors.white10 : const Color(0xFFEDF7EE)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: isSelected ? Colors.white : AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: isSelected ? AppColors.primaryGreen : (isDark ? Colors.white : AppColors.charcoal),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : AppColors.mutedGrey,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
