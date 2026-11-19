import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_card.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../../../core/widgets/fb_text_field.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/domain/models/distribution_record.dart';
import '../../donations/presentation/donation_provider.dart';

class DistributionRecordsScreen extends StatefulWidget {
  const DistributionRecordsScreen({super.key});

  @override
  State<DistributionRecordsScreen> createState() =>
      _DistributionRecordsScreenState();
}

class _DistributionRecordsScreenState extends State<DistributionRecordsScreen> {
  void _openLogDistributionModal(BuildContext context) {
    final donationProvider = context.read<DonationProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    final ngoId = user?.id ?? 'usr-ngo-201';
    final ngoName = user?.organizationName ?? 'Asha Children Foundation';

    // Find delivered or completed donations for this NGO
    final eligibleDonations = donationProvider.allDonations.where((d) {
      return (d.claimedByNgoId == ngoId ||
              d.dropoffAddress.contains(ngoName)) &&
          (d.status == DonationStatus.delivered ||
              d.status == DonationStatus.deliveredToNgo ||
              d.status == DonationStatus.completed ||
              d.status == DonationStatus.distributed);
    }).toList();

    // Fallback: If no specifically claimed delivered items yet, allow selecting from any delivered donation or recent claim
    final displayDonations = eligibleDonations.isNotEmpty
        ? eligibleDonations
        : donationProvider.allDonations
              .where(
                (d) =>
                    d.status == DonationStatus.delivered ||
                    d.status == DonationStatus.deliveredToNgo,
              )
              .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => _LogDistributionForm(
        eligibleDonations: displayDonations.isNotEmpty
            ? displayDonations
            : donationProvider.allDonations.take(5).toList(),
        ngoId: ngoId,
        ngoName: ngoName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final donationProvider = context.watch<DonationProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final ngoId = user?.id ?? 'usr-ngo-201';

    final records = donationProvider.getNgoDistributionRecords(ngoId);
    final allRecords = records.isNotEmpty
        ? records
        : donationProvider.distributionRecords;

    final totalServed = allRecords.fold<int>(
      0,
      (sum, r) => sum + r.headcountServed,
    );
    final totalQty = allRecords.fold<double>(
      0.0,
      (sum, r) => sum + r.quantityDistributed,
    );

    final dateFormat = DateFormat('EEE, d MMM yyyy - hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribution Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Log Distribution',
            onPressed: () => _openLogDistributionModal(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_chart),
        label: const Text('Log Distribution'),
        onPressed: () => _openLogDistributionModal(context),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Beneficiary Privacy Assurance Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Beneficiary Privacy Guard',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepGreen,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Aggregate metrics and community names only. No individual recipient personal information or identity documents are recorded.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.charcoal.withOpacity(0.85),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary Metrics Cards
            Row(
              children: [
                Expanded(
                  child: FBCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.people_alt,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'People Reached',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.mutedGrey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalServed',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                        ),
                        Text(
                          'Total Headcount Served',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FBCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.volunteer_activism,
                              color: AppColors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Units Handed Over',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.mutedGrey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalQty.toStringAsFixed(0),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.orange,
                              ),
                        ),
                        Text(
                          'Meals & Clothing Items',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Distribution Log History',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${allRecords.length} records',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.mutedGrey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Distribution Records List
            if (allRecords.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: FBEmptyState(
                  icon: Icons.checklist_rtl_rounded,
                  title: 'No Distributions Logged Yet',
                  description: 'When donations arrive at your shelter or distribution center, tap "Log Distribution" to record headcount and impact metrics.',
                  actionLabel: 'Log First Distribution',
                  onAction: () => _openLogDistributionModal(context),
                ),
              )
            else
              ...allRecords.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FBCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.handshake_outlined,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.beneficiaryGroup,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.charcoal,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'From: ${r.donationTitle}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppColors.mutedGrey),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${r.headcountServed} People',
                                style: const TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.scale,
                                  size: 16,
                                  color: AppColors.mutedGrey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${r.quantityDistributed.toStringAsFixed(0)} ${r.unit}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: AppColors.mutedGrey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateFormat.format(r.distributionDate),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.mutedGrey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (r.notes != null && r.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            r.notes!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.charcoal.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _LogDistributionForm extends StatefulWidget {
  final List<Donation> eligibleDonations;
  final String ngoId;
  final String ngoName;

  const _LogDistributionForm({
    required this.eligibleDonations,
    required this.ngoId,
    required this.ngoName,
  });

  @override
  State<_LogDistributionForm> createState() => _LogDistributionFormState();
}

class _LogDistributionFormState extends State<_LogDistributionForm> {
  final _formKey = GlobalKey<FormState>();
  final _beneficiaryController = TextEditingController();
  final _headcountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  Donation? _selectedDonation;
  final DateTime _distributionDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.eligibleDonations.isNotEmpty) {
      _selectedDonation = widget.eligibleDonations.first;
      _quantityController.text = _selectedDonation!.quantity.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _beneficiaryController.dispose();
    _headcountController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitDistribution() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDonation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a donation.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<DonationProvider>();

    final record = DistributionRecord(
      id: 'dist-${DateTime.now().millisecondsSinceEpoch}',
      donationId: _selectedDonation!.id,
      donationTitle: _selectedDonation!.title,
      ngoId: widget.ngoId,
      ngoName: widget.ngoName,
      beneficiaryGroup: _beneficiaryController.text.trim(),
      headcountServed: int.tryParse(_headcountController.text.trim()) ?? 1,
      quantityDistributed:
          double.tryParse(_quantityController.text.trim()) ??
          _selectedDonation!.quantity,
      unit: _selectedDonation!.unit,
      distributionDate: _distributionDate,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: DateTime.now(),
    );

    final success = await provider.recordDistribution(record);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Distribution record logged successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to log distribution record.',
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Log Beneficiary Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Select Delivered Donation
              Text(
                'Source Donation Received *',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedDonation?.id,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                items: widget.eligibleDonations.map((d) {
                  return DropdownMenuItem<String>(
                    value: d.id,
                    child: Text(
                      '${d.title} (${d.quantity.toStringAsFixed(0)} ${d.unit})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id != null) {
                    final found = widget.eligibleDonations.firstWhere((d) => d.id == id);
                    setState(() {
                      _selectedDonation = found;
                      _quantityController.text = found.quantity.toStringAsFixed(0);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Beneficiary Group / Community
              FBTextField(
                label: 'Beneficiary Group / Community Center *',
                controller: _beneficiaryController,
                hint: 'e.g. Swargate Night Shelter Residents',
                prefixIcon: const Icon(Icons.domain),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter beneficiary group name'
                    : null,
              ),
              const SizedBox(height: 16),

              // Headcount & Quantity in Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FBTextField(
                      label: 'Headcount Served *',
                      controller: _headcountController,
                      hint: 'e.g. 50',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.people),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter headcount';
                        }
                        final n = int.tryParse(val.trim());
                        if (n == null || n <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FBTextField(
                      label: 'Units Distributed *',
                      controller: _quantityController,
                      hint: 'e.g. 50',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.scale),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter quantity';
                        }
                        final n = double.tryParse(val.trim());
                        if (n == null || n <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              FBTextField(
                label: 'Distribution Notes / Observations',
                controller: _notesController,
                hint: 'e.g. Distributed during evening meal shift. Hot and well received.',
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Submit Button
              FBButton(
                label: 'Confirm & Log Distribution',
                icon: Icons.check_circle_outline,
                isLoading: _isSaving,
                onPressed: _submitDistribution,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
