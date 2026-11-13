import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fb_button.dart';
import '../auth_provider.dart';

class TermsAndConditionsModal extends StatefulWidget {
  final VoidCallback? onAccepted;

  const TermsAndConditionsModal({
    super.key,
    this.onAccepted,
  });

  static Future<bool> showIfNeeded(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated && !auth.hasAcceptedTerms) {
      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: TermsAndConditionsModal(),
        ),
      );
      return accepted ?? false;
    }
    return true;
  }

  @override
  State<TermsAndConditionsModal> createState() => _TermsAndConditionsModalState();
}

class _TermsAndConditionsModalState extends State<TermsAndConditionsModal> {
  bool _agreedToCharter = false;
  bool _agreedToDignity = false;
  bool _isSubmitting = false;

  bool get _canProceed => _agreedToCharter && _agreedToDignity;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.get('terms_title'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr.get('terms_subtitle'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Scrollable Core Charters
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _charterItem(
                    icon: Icons.restaurant,
                    title: '1. Food Safety & Hygiene (FSSAI)',
                    description:
                        'All surplus food must be freshly prepared, untainted, held at safe temperatures (Hot >60°C, Chilled <5°C), and collected before strict expiry deadlines. Visual inspection cannot substitute for safety certification.',
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 12),
                  _charterItem(
                    icon: Icons.checkroom,
                    title: '2. Clean Clothing Standards',
                    description:
                        'Garments, winterwear, and blankets must be washed, sanitized, dry, and in wearable functional condition. Torn or stained items are prohibited.',
                    color: AppColors.orange,
                  ),
                  const SizedBox(height: 12),
                  _charterItem(
                    icon: Icons.volunteer_activism,
                    title: '3. Zero Commercialization Policy',
                    description:
                        'Donated goods are 100% free and exclusively for vulnerable communities and shelter residents. Selling, bartering, or monetizing any donation is strictly illegal.',
                    color: AppColors.deepGreen,
                  ),
                  const SizedBox(height: 12),
                  _charterItem(
                    icon: Icons.security,
                    title: '4. Privacy & Location Obfuscation',
                    description:
                        'Exact donor street addresses remain encrypted and masked until an authorized volunteer courier or verified NGO shelter accepts the dispatch.',
                    color: AppColors.charcoal,
                  ),
                  const SizedBox(height: 12),
                  _charterItem(
                    icon: Icons.two_wheeler,
                    title: '5. Courier Dispatch & 2-Leg OTP',
                    description:
                        'Volunteers must verify the 4-digit pickup OTP at the donor premises and the 4-digit delivery OTP at the NGO shelter to confirm chain-of-custody transfer.',
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Checkbox 1
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreedToCharter,
                activeColor: AppColors.primaryGreen,
                onChanged: (val) => setState(() => _agreedToCharter = val ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    tr.get('terms_agree'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),

          // Checkbox 2
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreedToDignity,
                activeColor: AppColors.primaryGreen,
                onChanged: (val) => setState(() => _agreedToDignity = val ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    tr.get('terms_dignity'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final router = GoRouter.of(context);
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    await auth.logout();
                    if (mounted) {
                      nav.pop(false);
                      router.go('/login');
                    }
                  },
                  child: Text(
                    tr.get('decline_signout'),
                    style: const TextStyle(
                      color: AppColors.errorRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FBButton(
                  label: tr.get('accept_continue'),
                  isLoading: _isSubmitting,
                  onPressed: _canProceed
                      ? () async {
                          final nav = Navigator.of(context);
                          setState(() => _isSubmitting = true);
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          await auth.acceptTerms();
                          if (mounted) {
                            setState(() => _isSubmitting = false);
                            nav.pop(true);
                            widget.onAccepted?.call();
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _charterItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.charcoal,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
