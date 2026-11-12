import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/domain/models/donation.dart';
import 'donation_preview_screen.dart';

class DonateFoodScreen extends StatefulWidget {
  const DonateFoodScreen({super.key});

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
  DateTime _prepTime = DateTime.now().subtract(const Duration(hours: 1));
  bool _safetyCharterAgreed = false;
  String? _selectedImage;

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

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.user?.address != null) {
      _addressController.text = auth.user!.address!;
    }
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
      city: 'Pune',
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
    final dateFormat = DateFormat('EEE, d MMM - hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate Food Surplus'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text(
                'List Surplus Food',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Help verified local shelters rescue freshly prepared or packaged food.',
                style: TextStyle(color: AppColors.mutedGrey, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Image Upload / Selector
              const Text('Photo of Food / Packaging:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 130,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.warmCream,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        image: DecorationImage(
                          image: NetworkImage(_selectedImage ?? _sampleImages[0]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Select Photo:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
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
              const Text('Food Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _foodCategories.map((cat) {
                  final isSelected = _foodCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
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
                label: 'Food Name / Title',
                hint: 'e.g. 50 Boxes of Veg Pulao & Dal Tadka',
                controller: _titleController,
                prefixIcon: const Icon(Icons.restaurant, color: AppColors.mutedGrey),
                validator: (v) => v == null || v.trim().isEmpty ? 'Food title is required' : null,
              ),
              const SizedBox(height: 16),

              FBTextField(
                label: 'Description & Packaging Notes',
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
                      label: 'Quantity',
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
                      label: 'Unit',
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
              const Text('Holding Condition & Food Storage:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
              const Text('Collection Deadline (Must be picked up before):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectPickupDeadline,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryGreen, width: 1.2),
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
                label: 'Exact Pickup Address & Locality',
                hint: 'e.g. Shop 4, Green Cafe, MG Road, Camp, Pune',
                controller: _addressController,
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.mutedGrey),
                validator: (v) => v == null || v.trim().isEmpty ? 'Pickup address is required' : null,
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
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'I declare under FSSAI food safety norms that this surplus was cooked hygienically, stored appropriately, and is fit for human consumption.',
                        style: TextStyle(fontSize: 12, color: AppColors.charcoal, height: 1.3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              FBButton(
                label: 'Proceed to Preview Listing',
                icon: Icons.preview_outlined,
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
      label: Text(label),
      selected: isSelected,
      onSelected: (sel) {
        if (sel) setState(() => _selectedImage = url);
      },
    );
  }
}
