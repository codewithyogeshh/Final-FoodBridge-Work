import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
import 'auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? initialEmail;

  const ResetPasswordScreen({super.key, this.initialEmail});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    final success = await auth.resetPassword(
      email: email,
      newPassword: newPassword,
    );

    if (mounted) {
      if (success) {
        setState(() => _isSuccess = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully! Please sign in with your new credentials.'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Password reset failed. Please try again.'),
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
        title: const Text('Set New Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: _isSuccess ? _buildSuccessView() : _buildFormView(auth),
        ),
      ),
    );
  }

  Widget _buildFormView(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create New Password',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your new password must be at least 8 characters long and different from previous passwords.',
            style: TextStyle(color: AppColors.mutedGrey, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          FBTextField(
            label: 'Account Email Address',
            hint: 'user@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.mutedGrey),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) return 'Enter valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          FBTextField(
            label: 'New Password',
            hint: 'Min 8 characters',
            controller: _newPasswordController,
            obscureText: _obscureNew,
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.mutedGrey),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.mutedGrey,
              ),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'Password must be at least 8 characters long';
              return null;
            },
          ),
          const SizedBox(height: 16),
          FBTextField(
            label: 'Confirm New Password',
            hint: 'Re-enter your password',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.mutedGrey),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.mutedGrey,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _newPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),
          FBButton(
            label: 'Update Password',
            isLoading: auth.isLoading,
            onPressed: _handleResetPassword,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: const Text(
                'Cancel and Return to Sign In',
                style: TextStyle(color: AppColors.mutedGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline, size: 64, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 24),
        const Text(
          'Password Changed!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepGreen),
        ),
        const SizedBox(height: 10),
        const Text(
          'Your password has been successfully updated. You can now sign in to FoodBridge with your new credentials.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.mutedGrey, height: 1.4),
        ),
        const SizedBox(height: 32),
        FBButton(
          label: 'Sign In Now',
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
