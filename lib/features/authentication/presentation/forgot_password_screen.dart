import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../../../core/services/email_service.dart';
import 'auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();

    // Dispatch real email OTP via SMTP
    await EmailService.instance.sendForgotPasswordOtp(email);

    final success = await auth.sendPasswordResetEmail(email);

    if (mounted) {
      if (success) {
        setState(() => _emailSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link dispatched!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Unable to send reset instructions.'),
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
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: _emailSent ? _buildSuccessState() : _buildFormState(auth),
        ),
      ),
    );
  }

  Widget _buildFormState(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Forgot Your Password?',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the email associated with your FoodBridge account, and we will send a password reset verification link.',
            style: TextStyle(color: AppColors.mutedGrey, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 28),
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
          const SizedBox(height: 24),
          FBButton(
            label: 'Send Reset Link',
            isLoading: auth.isLoading,
            onPressed: _handleResetPassword,
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Back to Sign In',
                style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    final email = _emailController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined, size: 56, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 24),
        const Text(
          'Reset Link Dispatched!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.deepGreen,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We have sent password recovery instructions to:\n$email',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.mutedGrey, height: 1.4),
        ),
        const SizedBox(height: 32),
        FBButton(
          label: 'Proceed to Set New Password',
          onPressed: () => context.push('/reset-password?email=$email'),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => context.go('/login'),
            child: const Text(
              'Return to Sign In',
              style: TextStyle(color: AppColors.mutedGrey),
            ),
          ),
        ),
      ],
    );
  }
}
