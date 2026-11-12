import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../domain/models/app_user.dart';
import 'auth_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
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
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepGreen,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in with your FoodBridge credentials or choose a quick role profile below.',
                  style: TextStyle(color: AppColors.mutedGrey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Role selector chip group for demo exploration
                const Text(
                  'Quick Select Demo Profile:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.charcoal),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _roleFilterChip(UserRole.donor, 'Donor'),
                    _roleFilterChip(UserRole.ngo, 'NGO Shelter'),
                    _roleFilterChip(UserRole.volunteer, 'Volunteer'),
                    _roleFilterChip(UserRole.admin, 'Admin'),
                  ],
                ),
                const SizedBox(height: 20),

                FBTextField(
                  label: 'Email Address',
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
                  label: 'Password',
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
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
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
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.mutedGrey),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepGreen : AppColors.mutedGrey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          _fillDemoCredentials(role);
        }
      },
    );
  }
}
