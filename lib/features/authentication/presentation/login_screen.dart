import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_appearance_selector.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../../../core/widgets/foodbridge_logo.dart';
import '../domain/models/app_user.dart';
import 'auth_provider.dart';
import 'widgets/terms_and_conditions_modal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.donor;
  bool _obscurePassword = true;
  int _activeTab = 0; // 0: Email Login, 1: Phone Login

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoCredentials(UserRole role) {
    setState(() {
      _selectedRole = role;
      switch (role) {
        case UserRole.donor:
          _emailController.text = 'donor@foodbridge.org';
          _passwordController.text = 'Password123!';
          break;
        case UserRole.ngo:
          _emailController.text = 'ngo@foodbridge.org';
          _passwordController.text = 'Password123!';
          break;
        case UserRole.volunteer:
          _emailController.text = 'volunteer@foodbridge.org';
          _passwordController.text = 'Password123!';
          break;
        case UserRole.admin:
          _emailController.text = 'admin@foodbridge.org';
          _passwordController.text = 'Password123!';
          break;
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final email = _activeTab == 0
        ? _emailController.text.trim()
        : '${_phoneController.text.trim().replaceAll(' ', '')}@foodbridge.org';
    final password = _passwordController.text.trim();

    final success = await auth.login(
      email: email,
      password: password,
      requestedRole: _selectedRole,
    );

    if (mounted) {
      if (success) {
        // Enforce terms and conditions acceptance for first time login users
        if (!auth.hasAcceptedTerms) {
          final accepted = await TermsAndConditionsModal.showIfNeeded(context);
          if (!accepted) return;
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${auth.user?.fullName}!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );

        final role = auth.currentRole;
        switch (role) {
          case UserRole.ngo:
            context.go('/ngo');
            break;
          case UserRole.volunteer:
            context.go('/volunteer');
            break;
          case UserRole.admin:
            context.go('/admin');
            break;
          case UserRole.donor:
            context.go('/donor');
            break;
        }
      } else {
        final rawMsg = auth.errorMessage ?? 'Login failed. Please check your credentials.';
        final humanMsg = AppException.humanize(rawMsg);
        final isEmailNotConfirmed = rawMsg.toLowerCase().contains('email not verified') ||
            rawMsg.toLowerCase().contains('email_not_confirmed') ||
            rawMsg.toLowerCase().contains('email not confirmed');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(humanMsg),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 6),
            action: isEmailNotConfirmed
                ? SnackBarAction(
                    label: 'Verify OTP',
                    textColor: Colors.white,
                    onPressed: () {
                      context.push('/verify-otp?email=${Uri.encodeComponent(email)}&role=${_selectedRole.name}');
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tr = context.tr;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.signIn),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/onboarding');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: tr.language,
            onPressed: () => showLanguageBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: tr.appearance,
            onPressed: () => showAppearanceBottomSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Logo Header
                const Center(
                  child: FoodBridgeLogo(
                    size: 60,
                    showTagline: false,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    tr.welcomeBack,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepGreen,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    tr.get('login_journey'),
                    style: const TextStyle(color: AppColors.mutedGrey, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),

                // Segmented Pills [Email Login] | [Phone Login]
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : const Color(0xFFEFF5F1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeTab == 0
                                  ? (isDark ? AppColors.primaryGreen : AppColors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: _activeTab == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              tr.get('email_login'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _activeTab == 0
                                    ? (isDark ? Colors.white : AppColors.primaryGreen)
                                    : AppColors.mutedGrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeTab == 1
                                  ? (isDark ? AppColors.primaryGreen : AppColors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: _activeTab == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              tr.get('phone_login'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _activeTab == 1
                                    ? (isDark ? Colors.white : AppColors.primaryGreen)
                                    : AppColors.mutedGrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Form Fields
                if (_activeTab == 0)
                  FBTextField(
                    label: tr.email,
                    hint: 'user@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.mutedGrey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Email is required';
                      if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email address';
                      return null;
                    },
                  )
                else
                  FBTextField(
                    label: 'Phone Number',
                    hint: '+91 98200 12345',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.mutedGrey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Phone number required';
                      return null;
                    },
                  ),
                const SizedBox(height: 14),

                FBTextField(
                  label: tr.password,
                  hint: '••••••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.mutedGrey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.mutedGrey,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Password is required';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(
                      tr.forgotPassword,
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Solid green Login Pill Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 3,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            '${tr.signIn} (${_getLocalizedRole(tr, _selectedRole)})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),

                // OR Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'OR',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 14),

                // Continue with Google Button
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      _fillDemoCredentials(UserRole.donor);
                      _handleLogin();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF4285F4),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          tr.get('continue_with_google'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Demo Accounts Switcher Pill Chips
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : const Color(0xFFF4F9F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.mintLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.get('quick_profile'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _roleFilterChip(UserRole.donor, tr.donor),
                          _roleFilterChip(UserRole.ngo, tr.ngo),
                          _roleFilterChip(UserRole.volunteer, tr.volunteer),
                          _roleFilterChip(UserRole.admin, tr.admin),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Footer: Sign Up & Admin Portal Link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      tr.dontHaveAccount,
                      style: const TextStyle(color: AppColors.mutedGrey, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        minimumSize: const Size(48, 48),
                      ),
                      child: Text(
                        tr.register,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.admin_panel_settings_outlined, size: 16, color: AppColors.deepGreen),
                    label: const Text(
                      'Admin Portal Login →',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepGreen,
                      ),
                    ),
                    onPressed: () => context.push('/admin-login'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedRole(AppTranslations tr, UserRole role) {
    switch (role) {
      case UserRole.donor:
        return tr.donor;
      case UserRole.ngo:
        return tr.ngo;
      case UserRole.volunteer:
        return tr.volunteer;
      case UserRole.admin:
        return tr.admin;
    }
  }

  Widget _roleFilterChip(UserRole role, String label) {
    final isSelected = _selectedRole == role;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen,
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.charcoal,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => _fillDemoCredentials(role),
    );
  }
}
