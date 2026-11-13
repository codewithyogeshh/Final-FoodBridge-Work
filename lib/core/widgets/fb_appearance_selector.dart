import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_translations.dart';
import '../localization/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';

class FBAppearanceSelector extends StatelessWidget {
  final bool compact;

  const FBAppearanceSelector({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final tr = context.tr;

    final options = [
      _AppearanceOption(
        mode: ThemeMode.light,
        label: tr.themeLight,
        icon: Icons.light_mode_outlined,
        activeIcon: Icons.light_mode,
      ),
      _AppearanceOption(
        mode: ThemeMode.dark,
        label: tr.themeDark,
        icon: Icons.dark_mode_outlined,
        activeIcon: Icons.dark_mode,
      ),
      _AppearanceOption(
        mode: ThemeMode.system,
        label: tr.themeSystem,
        icon: Icons.brightness_auto_outlined,
        activeIcon: Icons.brightness_auto,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = themeProvider.themeMode == opt.mode;
          return Expanded(
            child: InkWell(
              onTap: () => themeProvider.setThemeMode(opt.mode),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  vertical: compact ? 8 : 12,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? opt.activeIcon : opt.icon,
                      size: compact ? 16 : 18,
                      color: isSelected
                          ? Colors.white
                          : AppColors.mutedGrey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      opt.label,
                      style: TextStyle(
                        fontSize: compact ? 12 : 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AppearanceOption {
  final ThemeMode mode;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _AppearanceOption({
    required this.mode,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// Helper function to open Appearance Sheet anywhere in the app
void showAppearanceBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: AppColors.primaryGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      ctx.tr.appearance,
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred visual appearance mode (Light, Dark, or System default).',
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedGrey,
                  ),
            ),
            const SizedBox(height: 20),
            const FBAppearanceSelector(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

/// Helper function to open Language Sheet anywhere in the app
void showLanguageBottomSheet(BuildContext context) {
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  final tr = context.tr;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.deepGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.translate,
                        color: AppColors.deepGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      tr.language,
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select language / भाषा निवडा / भाषा चुनें',
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedGrey,
                  ),
            ),
            const SizedBox(height: 16),
            _LanguageTile(
              code: 'en',
              title: 'English',
              subtitle: 'Primary Language',
              isSelected: localeProvider.locale.languageCode == 'en',
              onTap: () {
                localeProvider.setLanguageCode('en');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
            _LanguageTile(
              code: 'hi',
              title: 'हिंदी (Hindi)',
              subtitle: 'राष्ट्रभाषा • Hindi Translation',
              isSelected: localeProvider.locale.languageCode == 'hi',
              onTap: () {
                localeProvider.setLanguageCode('hi');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
            _LanguageTile(
              code: 'mr',
              title: 'मराठी (Marathi)',
              subtitle: 'महाराष्ट्र राज्य • Marathi Translation',
              isSelected: localeProvider.locale.languageCode == 'mr',
              onTap: () {
                localeProvider.setLanguageCode('mr');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.mutedGrey.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                code.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.charcoal,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppColors.deepGreen : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryGreen,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

