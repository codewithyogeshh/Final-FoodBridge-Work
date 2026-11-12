import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'donor';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // Route according to chosen role
        switch (_selectedRole) {
          case 'ngo':
            context.go('/ngo');
            break;
          case 'volunteer':
            context.go('/volunteer');
            break;
          case 'admin':
            context.go('/admin');
            break;
          case 'donor':
          default:
            context.go('/donor');
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                'Enter your credentials to access your FoodBridge dashboard.',
                style: TextStyle(color: AppColors.mutedGrey, fontSize: 14),
              ),
              const SizedBox(height: 28),
              FBTextField(
                label: 'Email Address',
                hint: 'user@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.mutedGrey),
              ),
              const SizedBox(height: 16),
              FBTextField(
                label: 'Password',
                hint: '••••••••••••',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.mutedGrey),
              ),
              const SizedBox(height: 16),
              // Role selector chip group for quick prototype / development testing
              const Text(
                'Login As Role:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.charcoal),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _roleFilterChip('donor', 'Donor'),
                  _roleFilterChip('ngo', 'NGO Shelter'),
                  _roleFilterChip('volunteer', 'Volunteer'),
                  _roleFilterChip('admin', 'Admin'),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FBButton(
                label: 'Sign In',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  Widget _roleFilterChip(String roleKey, String label) {
    final isSelected = _selectedRole == roleKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen.withOpacity(0.18),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepGreen : AppColors.mutedGrey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedRole = roleKey);
        }
      },
    );
  }
}
