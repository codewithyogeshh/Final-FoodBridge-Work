import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_appearance_selector.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
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
  final _emailController = TextEditingController(text: 'donor@foodbridge.org');
  final _passwordController = TextEditingController(text: 'Password123!');
  UserRole _selectedRole = UserRole.donor;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
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
    final email = _emailController.text.trim();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Login failed. Please check your credentials.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tr = context.tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.signIn),
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
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  tr.welcomeBack,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepGreen,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  tr.get('welcome_back_sub'),
                  style: const TextStyle(color: AppColors.mutedGrey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Role selector chip group for demo exploration
                Text(
                  tr.get('quick_profile'),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.charcoal),
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
                const SizedBox(height: 20),

                FBTextField(
                  label: tr.email,
                  hint: 'user@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.mutedGrey),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      tr.forgotPassword,
                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                FBButton(
                  label: 'Sign In as ${_selectedRole.displayName}',
                  isLoading: auth.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),

                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      tr.get('welcome_sub').contains('सत्यापित') ? 'खाते नाही का? ' : "Don't have an account? ",
                      style: const TextStyle(color: AppColors.mutedGrey),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text(
                        tr.register,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleFilterChip(UserRole role, String label) {
    final isSelected = _selectedRole == role;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen.withOpacity(0.18),
      backgroundColor: AppColors.borderLight.withOpacity(0.4),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepGreen : AppColors.charcoal,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) _fillDemoCredentials(role);
      },
    );
  }
}
