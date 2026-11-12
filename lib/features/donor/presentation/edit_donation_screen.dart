import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';

class EditDonationScreen extends StatefulWidget {
  final String donationId;

  const EditDonationScreen({
    super.key,
    required this.donationId,
  });

  @override
  State<EditDonationScreen> createState() => _EditDonationScreenState();
}

class _EditDonationScreenState extends State<EditDonationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _qtyController;
  late TextEditingController _addressController;
  late TextEditingController _allergenController;

  late DateTime _pickupDeadline;
  late String _storageCondition;
  bool _isSaving = false;
  Donation? _donation;

  @override
  void initState() {
    super.initState();
    final provider = context.read<DonationProvider>();
    _donation = provider.getDonationById(widget.donationId);

    _titleController = TextEditingController(text: _donation?.title ?? '');
    _descController = TextEditingController(text: _donation?.description ?? '');
    _qtyController =
        TextEditingController(text: _donation?.quantity.toStringAsFixed(0) ?? '1');
    _addressController =
        TextEditingController(text: _donation?.pickupAddress ?? '');
    _allergenController =
        TextEditingController(text: _donation?.allergenNotes ?? '');
    _pickupDeadline =
        _donation?.pickupDeadline ?? DateTime.now().add(const Duration(hours: 4));
    _storageCondition = _donation?.storageCondition ?? 'ambient';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    _addressController.dispose();
    _allergenController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate() || _donation == null) return;

    setState(() => _isSaving = true);

    final provider = context.read<DonationProvider>();
    final qty = double.tryParse(_qtyController.text.trim()) ?? _donation!.quantity;

    final updated = _donation!.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      quantity: qty,
      pickupAddress: _addressController.text.trim(),
      pickupDeadline: _pickupDeadline,
      allergenNotes: _allergenController.text.trim().isNotEmpty
          ? _allergenController.text.trim()
          : null,
      storageCondition: _storageCondition,
    );

    final success = await provider.updateDonation(updated);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation listing updated successfully!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Update failed.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _handleWithdraw() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Donation Listing?'),
        content: const Text(
          'Are you sure you want to withdraw this listing from the active community feed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Active'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Withdraw Listing'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<DonationProvider>();
      await provider.withdrawDonation(widget.donationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation listing withdrawn.')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_donation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Listing')),
        body: const Center(child: Text('Donation not found.')),
      );
    }

    final dateFormat = DateFormat('EEE, d MMM - hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
            onPressed: _handleWithdraw,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              FBTextField(
                label: 'Title',
                controller: _titleController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              FBTextField(
                label: 'Description & Packaging Notes',
                controller: _descController,
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              FBTextField(
                label: 'Quantity (${_donation!.unit})',
                controller: _qtyController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Enter number' : null,
              ),
              const SizedBox(height: 16),
              FBTextField(
                label: 'Pickup Address',
                controller: _addressController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              if (_donation!.isFood) ...[
                const Text(
                  'Holding Condition:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Ambient Room Temp'),
                      selected: _storageCondition == 'ambient',
                      onSelected: (sel) {
                        if (sel) setState(() => _storageCondition = 'ambient');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Hot-Holding (>63°C)'),
                      selected: _storageCondition == 'hot',
                      onSelected: (sel) {
                        if (sel) setState(() => _storageCondition = 'hot');
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
                  label: 'Allergen / Dietary Notes',
                  controller: _allergenController,
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Collection Deadline:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.primaryGreen),
                    const SizedBox(width: 10),
                    Text(
                      dateFormat.format(_pickupDeadline),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FBButton(
                label: 'Save Changes',
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 12),
              FBButton(
                label: 'Withdraw Listing',
                variant: FBButtonVariant.danger,
                onPressed: _handleWithdraw,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
