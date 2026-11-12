import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../domain/models/app_user.dart';
import 'auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final String? initialRole;

  const RegisterScreen({super.key, this.initialRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _orgController = TextEditingController();
  final _darpanController = TextEditingController();

  late UserRole _selectedRole;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = UserRole.fromString(widget.initialRole);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _orgController.dispose();
    _darpanController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the FoodBridge Safety and Privacy Charter.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: email,
      password: password,
      fullName: name,
      role: _selectedRole,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      organizationName: _orgController.text.trim().isNotEmpty ? _orgController.text.trim() : null,
      darpanId: _darpanController.text.trim().isNotEmpty ? _darpanController.text.trim() : null,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to FoodBridge, ${auth.user?.fullName}!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );

        switch (_selectedRole) {
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
            content: Text(auth.errorMessage ?? 'Registration failed.'),
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
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join FoodBridge',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Be a part of the real-time food and clothing recovery network.',
                style: TextStyle(color: AppColors.mutedGrey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              const Text(
                'Account Role:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.charcoal),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _roleOption(UserRole.donor, 'Donor', Icons.restaurant)),
                  const SizedBox(width: 8),
                  Expanded(child: _roleOption(UserRole.ngo, 'NGO Shelter', Icons.volunteer_activism)),
                  const SizedBox(width: 8),
                  Expanded(child: _roleOption(UserRole.volunteer, 'Volunteer', Icons.two_wheeler)),
                ],
              ),
              const SizedBox(height: 20),
              FBTextField(
                label: _selectedRole == UserRole.ngo ? 'Trust / Shelter Legal Name' : 'Full Name / Entity Name',
                hint: _selectedRole == UserRole.ngo ? 'Asha Welfare Foundation' : 'Ramesh Sharma',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.mutedGrey),
              ),
              const SizedBox(height: 16),
              FBTextField(
                label: 'Email Address',
                hint: 'name@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.mutedGrey),
              ),
              const SizedBox(height: 16),
              FBTextField(
                label: 'Mobile Number (For dispatch alerts)',
                hint: '+91 98765 43210',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.mutedGrey),
              ),
              const SizedBox(height: 16),
              if (_selectedRole == UserRole.ngo) ...[
                FBTextField(
                  label: 'NGO Darpan ID (NITI Aayog)',
                  hint: 'MH/2023/0192842',
                  controller: _darpanController,
                  prefixIcon: const Icon(Icons.verified_user_outlined, color: AppColors.mutedGrey),
                ),
                const SizedBox(height: 16),
              ],
              FBTextField(
                label: 'Password (min 8 characters)',
                hint: '••••••••••••',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.mutedGrey),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'I agree to the FoodBridge Safety Charter, Truth-in-Declaration guidelines, and Privacy Policy.',
                        style: TextStyle(fontSize: 12, color: AppColors.charcoal),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FBButton(
                label: 'Create Account',
                isLoading: auth.isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: AppColors.mutedGrey),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/login'),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
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

  Widget _roleOption(UserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.12) : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: isSelected ? AppColors.primaryGreen : AppColors.mutedGrey),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.deepGreen : AppColors.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
