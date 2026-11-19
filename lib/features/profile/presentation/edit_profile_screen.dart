import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/services/media_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/avatar_image_helper.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../../admin/presentation/admin_provider.dart';
import '../../authentication/domain/models/app_user.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/presentation/donation_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _serviceAreaController;
  late TextEditingController _orgController;
  String? _selectedTransport;
  String? _avatarPath;
  bool _isSaving = false;

  static const List<String> _transportOptions = [
    'Two-Wheeler / Scooter',
    'Bicycle',
    'Car / Van',
    'On Foot (Hyper-local)',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _serviceAreaController = TextEditingController(text: user?.serviceArea ?? '');
    _orgController = TextEditingController(text: user?.organizationName ?? '');
    final initialTransport = user?.transportType;
    if (initialTransport != null && _transportOptions.contains(initialTransport)) {
      _selectedTransport = initialTransport;
    } else {
      _selectedTransport = _transportOptions.first;
    }
    _avatarPath = user?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _serviceAreaController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Profile Photo',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                ),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await MediaService.instance.pickImageFromCamera();
                  if (file != null && mounted) {
                    setState(() => _avatarPath = file.path);
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.primaryGreen),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await MediaService.instance.pickImageFromGallery();
                  if (file != null && mounted) {
                    setState(() => _avatarPath = file.path);
                  }
                },
              ),
              if (_avatarPath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                  ),
                  title: const Text('Remove Photo', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _avatarPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    final bool photoRemoved = _avatarPath == null;
    String? uploadedAvatar = _avatarPath;
    if (_avatarPath != null &&
        !_avatarPath!.startsWith('http://') &&
        !_avatarPath!.startsWith('https://') &&
        !_avatarPath!.startsWith('data:image/')) {
      try {
        if (!kIsWeb && File(_avatarPath!).existsSync()) {
          uploadedAvatar = await MediaService.instance.uploadPhoto(
            file: XFile(_avatarPath!),
            folder: 'avatars',
          );
        }
      } catch (e) {
        debugPrint('[EditProfile] Avatar upload exception: $e');
        uploadedAvatar = _avatarPath;
      }
    }

    final success = await authProvider.updateUserProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      serviceArea: _serviceAreaController.text.trim().isNotEmpty ? _serviceAreaController.text.trim() : null,
      organizationName: _orgController.text.trim().isNotEmpty ? _orgController.text.trim() : null,
      transportType: user?.isVolunteer == true ? _selectedTransport : null,
      avatarUrl: uploadedAvatar,
      clearAvatar: photoRemoved,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      try {
        context.read<AdminProvider>().syncUsersWithAuth();
      } catch (_) {}
      try {
        context.read<DonationProvider>().syncWithUserProfiles();
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('प्रोफाइल यशस्वीरित्या अपडेट झाली! (Profile Updated Successfully)'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to update profile.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Widget _buildAvatarWidget() {
    final imageProvider = AvatarImageHelper.resolve(_avatarPath);

    return Center(
      child: Stack(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFFEDF7EE),
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.person, size: 54, color: AppColors.primaryGreen)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImagePickerSheet,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarWidget(),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _showImagePickerSheet,
                  icon: const Icon(Icons.photo_camera, size: 16, color: AppColors.primaryGreen),
                  label: const Text(
                    'Change Profile Photo',
                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Full Name
              FBTextField(
                controller: _nameController,
                label: 'Full Name (पूर्ण नाव)',
                hint: 'e.g. Rohit Kulkarni',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              FBTextField(
                controller: _phoneController,
                label: 'Phone Number (मोबाईल नंबर)',
                hint: '+91 98765 43210',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              const SizedBox(height: 16),

              // Address / Location
              FBTextField(
                controller: _addressController,
                label: 'Address / Location (पत्ता / शहर)',
                hint: 'e.g. Sadar Bazar, Satara 415001',
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              const SizedBox(height: 16),

              // Service Area / Neighborhood
              FBTextField(
                controller: _serviceAreaController,
                label: 'Service Area / Landmark (परिसर)',
                hint: 'e.g. Powai Naka / Rajwada / MIDC',
                prefixIcon: const Icon(Icons.map_outlined),
              ),
              const SizedBox(height: 16),

              // Organization Name for Donor/NGO
              if (user?.role == UserRole.ngo || user?.role == UserRole.donor) ...[
                FBTextField(
                  controller: _orgController,
                  label: user?.role == UserRole.ngo ? 'Shelter / NGO Name' : 'Business / Restaurant Name',
                  hint: 'e.g. Asha Children Foundation',
                  prefixIcon: const Icon(Icons.business_outlined),
                ),
                const SizedBox(height: 16),
              ],

              // Transport Type for Volunteer
              if (user?.isVolunteer == true) ...[
                Text(
                  'Transport Mode (डिलिव्हरी वाहन प्रकार)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppColors.textDarkPrimary : AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.charcoal,
                      ),
                      value: _transportOptions.contains(_selectedTransport)
                          ? _selectedTransport
                          : _transportOptions.first,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'Two-Wheeler / Scooter',
                          child: Text('🛵 Two-Wheeler / Scooter (बाईक/स्कूटर)'),
                        ),
                        DropdownMenuItem(
                          value: 'Bicycle',
                          child: Text('🚲 Bicycle (सायकल)'),
                        ),
                        DropdownMenuItem(
                          value: 'Car / Van',
                          child: Text('🚗 Car / Van (कार/व्हॅन)'),
                        ),
                        DropdownMenuItem(
                          value: 'On Foot (Hyper-local)',
                          child: Text('🚶 On Foot (पायी)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTransport = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const SizedBox(height: 8),
              ],

              // Save Button
              FBButton(
                label: 'Save Profile Changes (बदल जतन करा)',
                isLoading: _isSaving,
                onPressed: _saveProfile,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
