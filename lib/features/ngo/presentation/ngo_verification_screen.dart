import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../../authentication/domain/models/app_user.dart';
import '../../authentication/presentation/auth_provider.dart';

class NgoVerificationScreen extends StatefulWidget {
  const NgoVerificationScreen({super.key});

  @override
  State<NgoVerificationScreen> createState() => _NgoVerificationScreenState();
}

class _NgoVerificationScreenState extends State<NgoVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _legalNameController = TextEditingController();
  final _darpanIdController = TextEditingController();
  final _capacityController = TextEditingController(text: '80');
  final _addressController = TextEditingController();

  String? _uploadedDocName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user != null) {
      _legalNameController.text = user.organizationName ?? user.fullName;
      _darpanIdController.text = user.darpanId ?? 'MH/2023/DARPAN-4412';
      _addressController.text = user.address ?? 'Swargate, Pune, Maharashtra';
      _uploadedDocName = '12A_80G_Certificate.pdf';
    }
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _darpanIdController.dispose();
    _capacityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleUploadDoc() {
    setState(() {
      _uploadedDocName = 'Trust_Deed_80G_Verified.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document "Trust_Deed_80G_Verified.pdf" selected.'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_uploadedDocName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your 12A/80G or Trust Registration document.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification documents submitted for admin review.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final status = user?.ngoVerificationStatus ?? NgoVerificationStatus.verified;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Verification & 80G'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Verification Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: status == NgoVerificationStatus.verified
                      ? AppColors.primaryGreen.withOpacity(0.12)
                      : AppColors.warningOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: status == NgoVerificationStatus.verified
                        ? AppColors.primaryGreen
                        : AppColors.warningOrange,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == NgoVerificationStatus.verified
                          ? Icons.verified
                          : Icons.pending_actions,
                      color: status == NgoVerificationStatus.verified
                          ? AppColors.primaryGreen
                          : AppColors.warningOrange,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: status == NgoVerificationStatus.verified
                                  ? AppColors.deepGreen
                                  : AppColors.warningOrange,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Verified shelters receive priority dispatch and can claim hot food surpluses.',
                            style: TextStyle(fontSize: 12, color: AppColors.charcoal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              FBTextField(
                label: 'Trust / NGO Registered Name',
                hint: 'Asha Children Foundation',
                controller: _legalNameController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              FBTextField(
                label: 'NITI Aayog Darpan ID',
                hint: 'MH/2023/0192842',
                controller: _darpanIdController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              FBTextField(
                label: 'Shelter Beneficiary Capacity (Beds / Daily Meals)',
                hint: '80',
                controller: _capacityController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || int.tryParse(val) == null ? 'Enter valid number' : null,
              ),
              const SizedBox(height: 16),

              FBTextField(
                label: 'Physical Shelter / Distribution Address',
                hint: 'Plot 12, Swargate, Pune',
                controller: _addressController,
                maxLines: 2,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // Upload Certificate
              const Text(
                'Registration & Tax Exemption Proof',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoal),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _handleUploadDoc,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.upload_file_rounded, color: AppColors.primaryGreen, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _uploadedDocName ?? 'Upload 12A / 80G Certificate (PDF)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _uploadedDocName != null ? AppColors.charcoal : AppColors.mutedGrey,
                              ),
                            ),
                            const Text(
                              'Max 10MB • PDF, JPG or PNG',
                              style: TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _handleUploadDoc,
                        child: Text(_uploadedDocName != null ? 'Change' : 'Browse'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              FBButton(
                label: 'Update Verification Credentials',
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
