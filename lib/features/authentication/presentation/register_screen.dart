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
  final _formKey = GlobalKey<FormState>();

  // Shared controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  // Role-specific controllers
  final _orgController = TextEditingController();
  final _darpanController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _serviceAreaController = TextEditingController();

  // Selections
  late UserRole _selectedRole;
  String _selectedDonorCategory = 'Restaurant / Cafe';
  String _selectedAvailability = 'Flexible / On-Call';
  String _selectedTransport = 'Two-Wheeler / Scooter';
  String? _uploadedDocumentName;

  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  final List<String> _donorCategories = [
    'Restaurant / Cafe',
    'Hotel / Banquet',
    'Caterer / Events',
    'Supermarket / Retail',
    'Individual / Household',
  ];

  final List<String> _volunteerAvailabilities = [
    'Flexible / On-Call',
    'Weekdays Only',
    'Weekends Only',
    'Mornings (7 AM - 12 PM)',
    'Evenings (5 PM - 11 PM)',
  ];

  final List<String> _volunteerTransports = [
    'Two-Wheeler / Scooter',
    'Bicycle',
    'Car / Van',
    'On Foot (Hyper-local)',
  ];

  @override
  void initState() {
    super.initState();
    final role = UserRole.fromString(widget.initialRole);
    // Disallow admin role selection from deep-link or initial parameter
    _selectedRole = role == UserRole.admin ? UserRole.donor : role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _orgController.dispose();
    _darpanController.dispose();
    _contactPersonController.dispose();
    _serviceAreaController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the FoodBridge Safety and Privacy Charter to continue.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    final success = await auth.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
      role: _selectedRole,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      organizationName: _orgController.text.trim().isNotEmpty ? _orgController.text.trim() : null,
      darpanId: _darpanController.text.trim().isNotEmpty ? _darpanController.text.trim() : null,
      registrationNumber: _darpanController.text.trim().isNotEmpty ? _darpanController.text.trim() : null,
      contactPerson: _contactPersonController.text.trim().isNotEmpty ? _contactPersonController.text.trim() : null,
      verificationDocumentUrl: _uploadedDocumentName,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      serviceArea: _serviceAreaController.text.trim().isNotEmpty ? _serviceAreaController.text.trim() : null,
      donorCategory: _selectedRole == UserRole.donor ? _selectedDonorCategory : null,
      availability: _selectedRole == UserRole.volunteer ? _selectedAvailability : null,
      transportType: _selectedRole == UserRole.volunteer ? _selectedTransport : null,
    );

    if (mounted) {
      if (success) {
        if (_selectedRole == UserRole.ngo) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NGO registration submitted! Verification is pending administrator review.'),
              backgroundColor: AppColors.primaryGreen,
              duration: Duration(seconds: 4),
            ),
          );
          context.go('/ngo');
        } else if (_selectedRole == UserRole.volunteer) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome Rider ${auth.user?.fullName}! Ready to bridge the need.'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          context.go('/volunteer');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome to FoodBridge, ${auth.user?.fullName}!'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          context.go('/donor');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Registration failed. Please check the form.'),
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
          child: Form(
            key: _formKey,
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
                  'Select your role to configure your dedicated redistribution profile.',
                  style: TextStyle(color: AppColors.mutedGrey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Role selector tabs (Admin strictly excluded)
                const Text(
                  'Choose Your Role:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.charcoal),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _roleOption(UserRole.donor, 'Donor', Icons.storefront_outlined)),
                    const SizedBox(width: 8),
                    Expanded(child: _roleOption(UserRole.ngo, 'NGO Shelter', Icons.volunteer_activism_outlined)),
                    const SizedBox(width: 8),
                    Expanded(child: _roleOption(UserRole.volunteer, 'Volunteer', Icons.two_wheeler_outlined)),
                  ],
                ),
                const SizedBox(height: 24),

                // Dynamic Role Forms
                if (_selectedRole == UserRole.donor) _buildDonorForm(),
                if (_selectedRole == UserRole.ngo) _buildNgoForm(),
                if (_selectedRole == UserRole.volunteer) _buildVolunteerForm(),

                const SizedBox(height: 20),

                // Password with Visibility Toggle
                FBTextField(
                  label: 'Account Password',
                  hint: 'Min 8 characters with numbers',
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
                const SizedBox(height: 20),

                // Safety and Privacy Charter Checkbox
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
                          'I agree to the FoodBridge Safety Charter, FSSAI hygiene guidelines, and Privacy Policy.',
                          style: TextStyle(fontSize: 12, color: AppColors.charcoal, height: 1.3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                FBButton(
                  label: 'Register as ${_selectedRole.displayName}',
                  isLoading: auth.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),

                // Already have account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already registered? ',
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDonorForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FBTextField(
          label: 'Contact Person / Representative Name',
          hint: 'e.g. Vikram Joshi',
          controller: _nameController,
          prefixIcon: const Icon(Icons.person_outline, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().isEmpty ? 'Contact name is required' : null,
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Business / Establishment Name (Optional)',
          hint: 'e.g. The Green Leaf Bistro or Individual',
          controller: _orgController,
          prefixIcon: const Icon(Icons.business_outlined, color: AppColors.mutedGrey),
        ),
        const SizedBox(height: 16),
        const Text(
          'Donor Category:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.charcoal),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _donorCategories.map((cat) {
            final isSelected = _selectedDonorCategory == cat;
            return ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: AppColors.primaryGreen.withValues(alpha: 0.18),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.deepGreen : AppColors.charcoal,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (selected) {
                if (selected) setState(() => _selectedDonorCategory = cat);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Email Address',
          hint: 'donor@restaurant.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.mutedGrey),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
            return null;
          },
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Mobile Number (For pickup notifications)',
          hint: '+91 98200 12345',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().length < 10 ? 'Enter valid 10-digit mobile number' : null,
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Pickup Address & Locality',
          hint: 'Shop 4, MG Road, Camp, Pune',
          controller: _addressController,
          prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().isEmpty ? 'Address is required for pickups' : null,
        ),
      ],
    );
  }

  Widget _buildNgoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FBTextField(
          label: 'Trust / NGO Organisation Legal Name',
          hint: 'e.g. Asha Children Welfare Trust',
          controller: _orgController,
          prefixIcon: const Icon(Icons.account_balance_outlined, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().isEmpty ? 'Organisation name is required' : null,
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Authorized Officer / Contact Person',
          hint: 'e.g. Sunita Rao',
          controller: _contactPersonController,
          prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().isEmpty ? 'Contact person name is required' : null,
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Registration Details (Darpan / 12A / 80G No.)',
          hint: 'e.g. MH/2019/0219482 or 80G-PUN-114',
          controller: _darpanController,
          prefixIcon: const Icon(Icons.verified_user_outlined, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().isEmpty ? 'Registration or Darpan ID is required' : null,
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Official Contact Email',
          hint: 'contact@ashafoundation.org',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.mutedGrey),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
            return null;
          },
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Official Phone Number',
          hint: '+91 98220 54321',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().length < 10 ? 'Enter valid phone number' : null,
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Primary Service Area & City',
          hint: 'e.g. Swargate, Hadapsar, Pune',
          controller: _serviceAreaController,
          prefixIcon: const Icon(Icons.map_outlined, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().isEmpty ? 'Service area is required' : null,
        ),
        const SizedBox(height: 16),
        const Text(
          'Verification Document (12A / 80G / Darpan Certificate):',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.charcoal),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              _uploadedDocumentName = '80G_Tax_Exemption_Certificate.pdf';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document attached: 80G_Tax_Exemption_Certificate.pdf'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _uploadedDocumentName != null ? AppColors.primaryGreen : AppColors.borderLight,
                width: _uploadedDocumentName != null ? 1.6 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _uploadedDocumentName != null ? Icons.task_alt : Icons.upload_file_outlined,
                  color: _uploadedDocumentName != null ? AppColors.primaryGreen : AppColors.mutedGrey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _uploadedDocumentName ?? 'Tap to select Registration Document (PDF/JPG)',
                    style: TextStyle(
                      color: _uploadedDocumentName != null ? AppColors.deepGreen : AppColors.mutedGrey,
                      fontWeight: _uploadedDocumentName != null ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warningOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.warningOrange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NGO profiles remain in "Pending Review" until FoodBridge Administrators verify your official registration certificate.',
                  style: TextStyle(fontSize: 11, color: AppColors.charcoal, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVolunteerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FBTextField(
          label: 'Full Name',
          hint: 'e.g. Rohit Kulkarni',
          controller: _nameController,
          prefixIcon: const Icon(Icons.person_outline, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().isEmpty ? 'Full name is required' : null,
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Email Address',
          hint: 'volunteer@foodbridge.org',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.mutedGrey),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
            return null;
          },
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Mobile Number (Required for task dispatch & SMS OTP)',
          hint: '+91 97654 99887',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().length < 10 ? 'Enter valid 10-digit mobile number' : null,
        ),
        const SizedBox(height: 16),
        FBTextField(
          label: 'Preferred Operating Area / Locality',
          hint: 'e.g. Kothrud, Deccan, Pune',
          controller: _serviceAreaController,
          prefixIcon: const Icon(Icons.near_me_outlined, color: AppColors.mutedGrey),
          validator: (v) => v == null || v.trim().isEmpty ? 'Service area is required' : null,
        ),
        const SizedBox(height: 16),
        const Text(
          'Volunteer Availability Schedule:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.charcoal),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _volunteerAvailabilities.map((avail) {
            final isSelected = _selectedAvailability == avail;
            return ChoiceChip(
              label: Text(avail),
              selected: isSelected,
              selectedColor: AppColors.primaryGreen.withValues(alpha: 0.18),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.deepGreen : AppColors.charcoal,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (selected) {
                if (selected) setState(() => _selectedAvailability = avail);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Transport Availability & Mode:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.charcoal),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _volunteerTransports.map((trans) {
            final isSelected = _selectedTransport == trans;
            return ChoiceChip(
              label: Text(trans),
              selected: isSelected,
              selectedColor: AppColors.primaryGreen.withValues(alpha: 0.18),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.deepGreen : AppColors.charcoal,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (selected) {
                if (selected) setState(() => _selectedTransport = trans);
              },
            );
          }).toList(),
        ),
      ],
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
          color: isSelected ? AppColors.primaryGreen.withValues(alpha: 0.12) : AppColors.white,
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
