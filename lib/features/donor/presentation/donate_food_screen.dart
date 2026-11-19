import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/donation_image_widget.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/media_service.dart';
import '../../../core/services/ai_service.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';
import 'donation_preview_screen.dart';

class DonateFoodScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialQty;
  final String? initialDesc;

  const DonateFoodScreen({
    super.key,
    this.initialTitle,
    this.initialQty,
    this.initialDesc,
  });

  @override
  State<DonateFoodScreen> createState() => _DonateFoodScreenState();
}

class _DonateFoodScreenState extends State<DonateFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController(text: 'meals');
  final _addressController = TextEditingController();
  final _allergenController = TextEditingController();

  String _foodCategory = 'Cooked Meals';
  bool _isVeg = true;
  String _storageCondition = 'hot';
  DateTime _pickupDeadline = DateTime.now().add(const Duration(hours: 4));
  final DateTime _prepTime = DateTime.now().subtract(const Duration(hours: 1));
  bool _safetyCharterAgreed = true;
  String? _selectedImage;
  bool _isPosting = false;

  final List<String> _foodCategories = [
    'Cooked Meals',
    'Raw Groceries / Produce',
    'Bakery & Dairy',
    'Packaged / Dry Goods',
  ];

  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600', // Biryani
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600', // Fresh Salad/Bowls
    'https://images.unsplash.com/photo-1619860860774-1e2e17343432?w=600', // Groceries
  ];

  bool _isLocating = false;
  bool _isAnalyzingImage = false;

  Future<void> _fetchCurrentLocationAddress() async {
    setState(() => _isLocating = true);
    try {
      final pos = await LocationService.instance.getCurrentPosition();
      final address = await LocationService.instance.getAddressFromCoordinates(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _addressController.text = address;
          _isLocating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 Live GPS Address set: $address'),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _captureFromCamera() async {
    final xfile = await MediaService.instance.pickImageFromCamera();
    if (xfile != null && mounted) {
      setState(() {
        _selectedImage = xfile.path;
      });
      _runAiScanner(xfile.path);
    }
  }

  Future<void> _pickFromGallery() async {
    final xfile = await MediaService.instance.pickImageFromGallery();
    if (xfile != null && mounted) {
      setState(() {
        _selectedImage = xfile.path;
      });
      _runAiScanner(xfile.path);
    }
  }

  Future<void> _runAiScanner(String path) async {
    setState(() => _isAnalyzingImage = true);
    try {
      final result = await AIService().analyzeFoodPhoto(imagePath: path);
      if (mounted) {
        setState(() {
          _isAnalyzingImage = false;
        });
        _showAiSuggestionDialog(result);
      }
    } catch (_) {
      if (mounted) setState(() => _isAnalyzingImage = false);
    }
  }

  void _showAiSuggestionDialog(FoodImageAnalysisResult res) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppColors.primaryGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Gemini AI Quality Scan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Detected: ${res.detectedTitle}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Category: ${res.category} • Approx: ${res.estimatedPortions.toInt()} ${res.unit}'),
              const SizedBox(height: 4),
              Text('Packaging Tip: ${res.packagingNotes}', style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Keep Manual'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                      setState(() {
                        _titleController.text = res.detectedTitle;
                        _quantityController.text = '${res.estimatedPortions.toInt()}';
                        _unitController.text = res.unit;
                        _foodCategory = res.category;
                        _isVeg = res.isVeg;
                        _storageCondition = res.storageCondition;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✨ AI details applied to donation form!'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply AI Details'),
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

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _titleController.text = widget.initialTitle ?? 'Cooked Meals (Fresh Surplus)';
    _quantityController.text = widget.initialQty ?? '10';
    _descriptionController.text = widget.initialDesc ?? 'Freshly prepared wholesome food, hygienically packed in food containers.';
    if (auth.user?.address != null && auth.user!.address!.trim().isNotEmpty) {
      _addressController.text = auth.user!.address!;
    } else {
      _addressController.text = 'Powai Naka, Satara';
    }
    _safetyCharterAgreed = true;
    _selectedImage = _sampleImages[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _addressController.dispose();
    _allergenController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _pickupDeadline,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3)),
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

    if (!_safetyCharterAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please acknowledge the FSSAI Food Safety and Hygiene Charter.'),
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

    String finalImageUrl = _selectedImage ?? _sampleImages[0];
    if (_selectedImage != null &&
        !_selectedImage!.startsWith('http://') &&
        !_selectedImage!.startsWith('https://')) {
      try {
        final uploaded = await MediaService.instance.uploadPhoto(
          file: XFile(_selectedImage!),
          folder: 'food',
        );
        finalImageUrl = uploaded;
      } catch (e) {
        debugPrint('[DonateFoodScreen] Storage upload error: $e');
      }
    }

    final donation = Donation(
      id: 'food-${DateTime.now().millisecondsSinceEpoch}',
      donorId: user?.id ?? 'usr-donor-101',
      donorName: user?.organizationName ?? user?.fullName ?? 'FoodBridge Donor',
      donorPhone: user?.phone ?? '+91 98200 12345',
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'Cooked Meals (Fresh Surplus)',
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Freshly prepared wholesome food, hygienically packed in food containers.',
      quantity: qty,
      unit: _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : 'meals',
      type: DonationType.food,
      status: DonationStatus.available,
      pickupAddress: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : (user?.address ?? 'Powai Naka, Satara'),
      city: _addressController.text.toLowerCase().contains('pune')
          ? 'Pune'
          : (_addressController.text.toLowerCase().contains('mumbai') ? 'Mumbai' : 'Satara'),
      createdAt: DateTime.now(),
      pickupDeadline: _pickupDeadline,
      prepTime: _prepTime,
      isVeg: _isVeg,
      storageCondition: _storageCondition,
      allergenNotes: _allergenController.text.trim().isNotEmpty ? _allergenController.text.trim() : null,
      safetyCharterAgreed: _safetyCharterAgreed,
      imageUrl: finalImageUrl,
      pickupOtp: '${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000))}',
      deliveryOtp: '${(1000 + ((DateTime.now().millisecondsSinceEpoch ~/ 7) % 9000))}',
      dropoffAddress: 'Asha Children Foundation, Sadar Bazar, Satara',
    );

    final success = await donationProvider.createDonation(donation);
    if (!mounted) return;
    setState(() => _isPosting = false);

    if (success) {
      _showSuccessDialog(donation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(donationProvider.errorMessage ?? 'Failed to publish donation.'),
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
        actionsOverflowButtonSpacing: 8,
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Donation Posted!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your food donation "${donation.title}" is now active.',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verified NGOs and volunteers in Satara have been notified immediately.',
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
                    Expanded(
                      child: Text(
                        'Pickup OTP: ${donation.pickupOtp}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepGreen,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

    if (!_safetyCharterAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please acknowledge the FSSAI Food Safety and Hygiene Charter.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final qty = double.tryParse(_quantityController.text.trim()) ?? 10.0;

    final donation = Donation(
      id: 'food-${DateTime.now().millisecondsSinceEpoch}',
      donorId: user?.id ?? 'usr-donor-101',
      donorName: user?.organizationName ?? user?.fullName ?? 'FoodBridge Donor',
      donorPhone: user?.phone ?? '+91 98200 12345',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      quantity: qty,
      unit: _unitController.text.trim(),
      type: DonationType.food,
      status: DonationStatus.available,
      pickupAddress: _addressController.text.trim(),
      city: _addressController.text.toLowerCase().contains('pune')
          ? 'Pune'
          : (_addressController.text.toLowerCase().contains('mumbai') ? 'Mumbai' : 'Satara'),
      createdAt: DateTime.now(),
      pickupDeadline: _pickupDeadline,
      prepTime: _prepTime,
      isVeg: _isVeg,
      storageCondition: _storageCondition,
      allergenNotes: _allergenController.text.trim().isNotEmpty ? _allergenController.text.trim() : null,
      safetyCharterAgreed: _safetyCharterAgreed,
      imageUrl: _selectedImage ?? _sampleImages[0],
      pickupOtp: '${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000))}',
      deliveryOtp: '${(1000 + ((DateTime.now().millisecondsSinceEpoch ~/ 7) % 9000))}',
      dropoffAddress: 'Asha Children Foundation, Sadar Bazar, Satara',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.get('donate_food_title')),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text(
                tr.get('list_surplus_food'),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                tr.get('list_surplus_food_sub'),
                style: const TextStyle(color: AppColors.mutedGrey, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Image Upload / Selector
              const Text('Photo of Food / Packaging:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                      child: SizedBox(
                        width: 120,
                        height: 160,
                        child: DonationImageWidget(
                          imageUrl: _selectedImage,
                          isFood: true,
                          width: 120,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Select / Snap:',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_isAnalyzingImage)
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  ActionChip(
                                    avatar: const Icon(Icons.camera_alt, size: 14, color: AppColors.primaryGreen),
                                    label: const Text('Camera', style: TextStyle(fontSize: 11)),
                                    onPressed: _captureFromCamera,
                                  ),
                                  ActionChip(
                                    avatar: const Icon(Icons.photo_library, size: 14, color: AppColors.primaryGreen),
                                    label: const Text('Gallery', style: TextStyle(fontSize: 11)),
                                    onPressed: _pickFromGallery,
                                  ),
                                  ActionChip(
                                    avatar: const Icon(Icons.auto_awesome, size: 14, color: AppColors.orange),
                                    label: const Text('AI Scan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    onPressed: () => _runAiScanner(_selectedImage ?? _sampleImages[0]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  _photoChip('Hot Biryani', _sampleImages[0]),
                                  _photoChip('Fresh Meals', _sampleImages[1]),
                                  _photoChip('Groceries', _sampleImages[2]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),

              // Food Category
              Text(tr.get('food_category'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _foodCategories.map((cat) {
                  final isSelected = _foodCategory == cat;
                  final localizedCat = cat == 'Cooked Meals'
                      ? tr.get('cooked_meals')
                      : cat == 'Raw Groceries / Produce'
                          ? tr.get('raw_groceries')
                          : cat == 'Bakery & Dairy'
                              ? tr.get('bakery_dairy')
                              : tr.get('packaged_goods');
                  return ChoiceChip(
                    label: Text(localizedCat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen.withValues(alpha: 0.18),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.deepGreen : AppColors.charcoal,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (sel) {
                      if (sel) setState(() => _foodCategory = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              FBTextField(
                label: tr.get('food_title'),
                hint: 'e.g. 50 Boxes of Veg Pulao & Dal Tadka',
                controller: _titleController,
                prefixIcon: const Icon(Icons.restaurant, color: AppColors.mutedGrey),
                validator: (v) => v == null || v.trim().isEmpty ? 'Food title is required' : null,
              ),
              const SizedBox(height: 16),

              FBTextField(
                label: tr.get('food_desc'),
                hint: 'e.g. Freshly cooked for corporate lunch. Sealed in foil meal trays.',
                controller: _descriptionController,
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Quantity & Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: FBTextField(
                      label: tr.get('quantity_and_unit'),
                      hint: 'e.g. 50',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FBTextField(
                      label: tr.get('meals_unit'),
                      hint: 'meals, kg, boxes',
                      controller: _unitController,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Veg / Non-Veg
              Row(
                children: [
                  const Text('Dietary Type:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 10, color: AppColors.primaryGreen),
                        SizedBox(width: 4),
                        Text('Pure Veg'),
                      ],
                    ),
                    selected: _isVeg,
                    selectedColor: AppColors.primaryGreen.withValues(alpha: 0.18),
                    onSelected: (sel) {
                      if (sel) setState(() => _isVeg = true);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 10, color: Colors.brown),
                        SizedBox(width: 4),
                        Text('Non-Veg'),
                      ],
                    ),
                    selected: !_isVeg,
                    selectedColor: Colors.brown.withValues(alpha: 0.18),
                    onSelected: (sel) {
                      if (sel) setState(() => _isVeg = false);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Holding Condition
              Text(tr.get('storage_condition'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Hot-Holding (>63°C)'),
                    selected: _storageCondition == 'hot',
                    onSelected: (sel) {
                      if (sel) setState(() => _storageCondition = 'hot');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Ambient Room Temp'),
                    selected: _storageCondition == 'ambient',
                    onSelected: (sel) {
                      if (sel) setState(() => _storageCondition = 'ambient');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Chilled (<5°C)'),
                    selected: _storageCondition == 'chilled',
                    onSelected: (sel) {
                      if (sel) setState(() => _storageCondition = 'chilled');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              FBTextField(
                label: 'Allergen / Dietary Information (If known)',
                hint: 'e.g. Contains dairy & cashews, or Gluten-Free',
                controller: _allergenController,
                prefixIcon: const Icon(Icons.warning_amber_rounded, color: AppColors.mutedGrey),
              ),
              const SizedBox(height: 16),

              // Collection Deadline
              Text(tr.get('pickup_deadline'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectPickupDeadline,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.primaryAccentDark : AppColors.primaryGreen,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.primaryGreen, size: 20),
                          const SizedBox(width: 10),
                          Text(dateFormat.format(_pickupDeadline), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const Icon(Icons.edit_calendar_outlined, size: 18, color: AppColors.primaryGreen),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              FBTextField(
                label: tr.get('pickup_address'),
                hint: 'e.g. Shop 4, Green Cafe, Powai Naka, Satara',
                controller: _addressController,
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.mutedGrey),
                suffixIcon: IconButton(
                  icon: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                        )
                      : const Icon(Icons.my_location, color: AppColors.primaryGreen),
                  tooltip: 'Fetch Live GPS Location',
                  onPressed: _fetchCurrentLocationAddress,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Pickup address is required' : null,
              ),
              const SizedBox(height: 16),

              // Auto Notify Nearby NGOs Switch (Matching Reference Image)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cell_tower, color: AppColors.primaryGreen, size: 22),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto Notify Nearby NGOs',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Instant dispatch broadcast to shelters within 5km',
                              style: TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: true,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Safety Charter
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _safetyCharterAgreed,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (val) => setState(() => _safetyCharterAgreed = val ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        tr.get('fssai_pledge_desc'),
                        style: const TextStyle(fontSize: 12, color: AppColors.charcoal, height: 1.3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              FBButton(
                label: tr.get('publish_food'),
                icon: Icons.volunteer_activism_outlined,
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoChip(String label, String url) {
    final isSelected = _selectedImage == url;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      onSelected: (sel) {
        if (sel) setState(() => _selectedImage = url);
      },
    );
  }
}
