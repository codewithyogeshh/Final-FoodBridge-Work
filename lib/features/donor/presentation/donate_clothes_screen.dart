import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';
import 'donation_preview_screen.dart';

class DonateClothesScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialQty;
  final String? initialDesc;

  const DonateClothesScreen({
    super.key,
    this.initialTitle,
    this.initialQty,
    this.initialDesc,
  });

  @override
  State<DonateClothesScreen> createState() => _DonateClothesScreenState();
}

class _DonateClothesScreenState extends State<DonateClothesScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController(text: 'pieces');
  final _addressController = TextEditingController();

  String _clothingCategory = 'Winter Wear';
  String _targetSize = 'Free Size / Mixed';
  String _conditionGrade = 'Like New';
  DateTime _pickupDeadline = DateTime.now().add(const Duration(days: 3));
  bool _cleanlinessDeclarationAgreed = true;
  String? _selectedImage;
  bool _isPosting = false;

  final List<String> _clothingCategories = [
    'Winter Wear',
    'Blankets & Quilts',
    'Kids Wear',
    'Adult Clothing',
    'School Uniforms',
  ];

  final List<String> _sizeOptions = [
    'Kids (0-5 yrs)',
    'Kids (6-12 yrs)',
    'Adults S/M',
    'Adults L/XL',
    'Free Size / Mixed',
  ];

  final List<String> _conditionOptions = [
    'Brand New',
    'Like New',
    'Gently Used',
  ];

  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600', // Sweaters & warm wear
    'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?w=600', // Neat folded clothes
    'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=600', // Kids & shirts
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _titleController.text = widget.initialTitle ?? 'Clean Clothes & Warm Wear';
    _quantityController.text = widget.initialQty ?? '10';
    _descriptionController.text = widget.initialDesc ?? 'Clean, washed, tear-free clothes ready for redistribution.';
    if (auth.user?.address != null) {
      _addressController.text = auth.user!.address!;
    } else {
      _addressController.text = 'Shop 4, MG Road, Camp, Pune';
    }
    _cleanlinessDeclarationAgreed = true;
    _selectedImage = _sampleImages[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _pickupDeadline,
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_pickupDeadline),
      );
      if (time != null && mounted) {
        setState(() {
          _pickupDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _postDonationDirectly() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_cleanlinessDeclarationAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please acknowledge the hygiene and cleanliness declaration.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);
    final auth = context.read<AuthProvider>();
    final donationProvider = context.read<DonationProvider>();
    final user = auth.user;
    final qty = double.tryParse(_quantityController.text.trim()) ?? 10.0;

    final donation = Donation(
      id: 'cloth-${DateTime.now().millisecondsSinceEpoch}',
      donorId: user?.id ?? 'usr-donor-101',
      donorName: user?.organizationName ?? user?.fullName ?? 'FoodBridge Donor',
      donorPhone: user?.phone ?? '+91 98200 12345',
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'Clean Clothes & Warm Wear',
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Clean, washed, tear-free clothes ready for redistribution.',
      quantity: qty,
      unit: _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : 'pieces',
      type: DonationType.clothing,
      status: DonationStatus.available,
      pickupAddress: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : (user?.address ?? 'Camp, Pune'),
      city: 'Pune',
      createdAt: DateTime.now(),
      pickupDeadline: _pickupDeadline,
      clothingCategory: _clothingCategory,
      targetSize: _targetSize,
      conditionGrade: _conditionGrade,
      isWashedAndClean: true,
      safetyCharterAgreed: true,
      imageUrl: _selectedImage ?? _sampleImages[0],
      pickupOtp: '${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000))}',
      deliveryOtp: '${(1000 + ((DateTime.now().millisecondsSinceEpoch ~/ 7) % 9000))}',
      dropoffAddress: 'Goonj Community Hub, Swargate, Pune',
    );

    final success = await donationProvider.createDonation(donation);
    if (!mounted) return;
    setState(() => _isPosting = false);

    if (success) {
      _showSuccessDialog(donation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(donationProvider.errorMessage ?? 'Failed to publish clothing donation.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _showSuccessDialog(Donation donation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Clothes Donation Posted!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your clothing donation "${donation.title}" is now active.',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Local NGOs and relief partners in Pune have been notified immediately.',
              style: TextStyle(color: AppColors.mutedGrey, fontSize: 13, height: 1.3),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.key, color: AppColors.primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Pickup OTP: ${donation.pickupOtp}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/donor');
            },
            child: const Text('Dashboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/donor/my-donations');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View in My Donations'),
          ),
        ],
      ),
    );
  }

  void _handleProceedToPreview() {
    if (!_formKey.currentState!.validate()) return;

    if (!_cleanlinessDeclarationAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please acknowledge the hygiene and cleanliness declaration.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final qty = double.tryParse(_quantityController.text.trim()) ?? 10.0;

    final donation = Donation(
      id: 'cloth-${DateTime.now().millisecondsSinceEpoch}',
      donorId: user?.id ?? 'usr-donor-101',
      donorName: user?.organizationName ?? user?.fullName ?? 'FoodBridge Donor',
      donorPhone: user?.phone ?? '+91 98200 12345',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      quantity: qty,
      unit: _unitController.text.trim(),
      type: DonationType.clothing,
      status: DonationStatus.available,
      pickupAddress: _addressController.text.trim(),
      city: 'Pune',
      createdAt: DateTime.now(),
      pickupDeadline: _pickupDeadline,
      clothingCategory: _clothingCategory,
      targetSize: _targetSize,
      conditionGrade: _conditionGrade,
      isWashedAndClean: true,
      safetyCharterAgreed: true,
      imageUrl: _selectedImage ?? _sampleImages[0],
      pickupOtp: '${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000))}',
      deliveryOtp: '${(1000 + ((DateTime.now().millisecondsSinceEpoch ~/ 7) % 9000))}',
      dropoffAddress: 'Asha Children Foundation, Swargate, Pune',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationPreviewScreen(donation: donation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final dateFormat = DateFormat('EEE, d MMM - hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.get('donate_clothes_title')),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.checkroom, color: AppColors.primaryGreen, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr.get('list_clothes'),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepGreen,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr.get('list_clothes_sub'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.charcoal.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title
              FBTextField(
                label: 'Listing Title *',
                controller: _titleController,
                hint: 'e.g. 20 Warm Winter Jackets and Shawls',
                prefixIcon: const Icon(Icons.title),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (val.trim().length < 5) {
                    return 'Title should be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Selector
              Text(
                'Clothing Category *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _clothingCategories.map((cat) {
                  final isSelected = _clothingCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.charcoal,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _clothingCategory = cat);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Size Selector
              Text(
                'Target Size / Group *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sizeOptions.map((size) {
                  final isSelected = _targetSize == size;
                  return ChoiceChip(
                    label: Text(size),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.charcoal,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _targetSize = size);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Condition Grade
              Text(
                'Condition Grade *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _conditionOptions.map((cond) {
                  final isSelected = _conditionGrade == cond;
                  return ChoiceChip(
                    label: Text(cond),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.charcoal,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _conditionGrade = cond);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Quantity & Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: FBTextField(
                      label: 'Quantity *',
                      controller: _quantityController,
                      hint: 'e.g. 15',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.numbers),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter count';
                        }
                        final n = double.tryParse(val.trim());
                        if (n == null || n <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FBTextField(
                      label: 'Unit *',
                      controller: _unitController,
                      hint: 'e.g. pieces',
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter unit' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              FBTextField(
                label: 'Description & Details *',
                controller: _descriptionController,
                hint: 'Describe colors, fabric materials, packaging (e.g. packed in 2 clean waterproof plastic bags).',
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Pickup Address
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FBTextField(
                    label: 'Pickup Address (Donor Location) *',
                    controller: _addressController,
                    hint: 'Building, Street, Landmark, Pune',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    maxLines: 2,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter pickup address' : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Exact house/flat number is kept private from public feeds until pickup.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedGrey),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pickup Deadline
              Text(
                'Collection Deadline *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectPickupDeadline,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.mutedGrey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppColors.primaryGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateFormat.format(_pickupDeadline),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.edit_calendar, size: 20, color: AppColors.mutedGrey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Image Selector
              Text(
                'Item Photo / Proof *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleImages.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final img = _sampleImages[idx];
                    final isSelected = (_selectedImage ?? _sampleImages[0]) == img;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedImage = img),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                img,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.checkroom, color: AppColors.mutedGrey),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Cleanliness & Quality Declaration
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warmCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.orange.withOpacity(0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _cleanlinessDeclarationAgreed,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) {
                        setState(() => _cleanlinessDeclarationAgreed = val ?? false);
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _cleanlinessDeclarationAgreed = !_cleanlinessDeclarationAgreed);
                        },
                        child: Text(
                          'I declare that all clothes are freshly laundered, clean, tear-free and hygienically packed ready for immediate wearing.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.charcoal,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Direct Post and Preview Listing Buttons
              FBButton(
                label: tr.get('publish_clothes'),
                icon: Icons.checkroom_outlined,
                isLoading: _isPosting,
                onPressed: _postDonationDirectly,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.preview_outlined, size: 18),
                label: Text(tr.get('preview_donation')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleProceedToPreview,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
