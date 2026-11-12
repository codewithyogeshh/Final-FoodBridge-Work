import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/widgets/fb_button.dart';
import '../../authentication/domain/models/app_user.dart';
import '../../authentication/presentation/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                  child: const Icon(Icons.person, color: AppColors.primaryGreen, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'FoodBridge Member',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${user?.role.displayName ?? "Donor"} ${user?.organizationName != null ? "• ${user!.organizationName}" : ""}',
                        style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.phone ?? user?.email ?? 'contact@foodbridge.org',
                        style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Role Switcher for Development / Demo Exploration
          const Text(
            'SWITCH ACTIVE ROLE VIEW',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedGrey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                _menuTile(
                  Icons.restaurant,
                  'Donor Dashboard',
                  () {
                    auth.switchRole(UserRole.donor);
                    context.go('/donor');
                  },
                ),
                const Divider(),
                _menuTile(
                  Icons.volunteer_activism,
                  'NGO Shelter Dashboard',
                  () {
                    auth.switchRole(UserRole.ngo);
                    context.go('/ngo');
                  },
                ),
                const Divider(),
                _menuTile(
                  Icons.two_wheeler,
                  'Volunteer "Rider Mode"',
                  () {
                    auth.switchRole(UserRole.volunteer);
                    context.go('/volunteer');
                  },
                ),
                const Divider(),
                _menuTile(
                  Icons.admin_panel_settings,
                  'Admin Console',
                  () {
                    auth.switchRole(UserRole.admin);
                    context.go('/admin');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preferences & Accessibility
          const Text(
            'PREFERENCES & ACCESSIBILITY',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedGrey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.deepGreen),
                  title: const Text('Dark Mode / Rider Night Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  value: themeProvider.isDarkMode,
                  activeThumbColor: AppColors.primaryGreen,
                  onChanged: (val) => themeProvider.toggleTheme(),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.deepGreen),
                  title: const Text('Language / भाषा', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: DropdownButton<Locale>(
                    value: localeProvider.locale,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: Locale('en'), child: Text('English')),
                      DropdownMenuItem(value: Locale('hi'), child: Text('हिंदी (Hindi)')),
                      DropdownMenuItem(value: Locale('mr'), child: Text('मराठी (Marathi)')),
                    ],
                    onChanged: (loc) {
                      if (loc != null) localeProvider.setLocale(loc);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Logout Button
          FBButton(
            label: 'Sign Out',
            variant: FBButtonVariant.danger,
            icon: Icons.logout,
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.mutedGrey),
      onTap: onTap,
    );
  }
}
