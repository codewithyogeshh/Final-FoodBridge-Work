import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/fb_appearance_selector.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../authentication/presentation/widgets/terms_and_conditions_modal.dart';
import '../../donations/domain/models/donation.dart';
import '../../donations/presentation/donation_provider.dart';
import 'widgets/volunteer_task_detail_sheet.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TermsAndConditionsModal.showIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final auth = context.watch<AuthProvider>();
    final donationProvider = context.watch<DonationProvider>();
    final currentUser = auth.user;

    final volunteerId = currentUser?.id ?? 'usr-vol-303';
    final activeTasks = donationProvider.getVolunteerActiveTasks(volunteerId);
    final availableTasks = donationProvider.volunteerAvailableTasks;
    final completedTasks = donationProvider.getVolunteerCompletedTasks(volunteerId);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.volunteerDispatch),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: tr.language,
            onPressed: () => showLanguageBottomSheet(context),
          ),
          IconButton(
            icon: Icon(themeProvider.appearanceIcon),
            tooltip: tr.appearance,
            onPressed: () => showAppearanceBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Delivery History',
            onPressed: () => context.push('/volunteer/history'),
          ),
          Row(
            children: [
              Text(
                _isOnline ? tr.online : tr.offline,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _isOnline ? AppColors.primaryGreen : AppColors.mutedGrey,
                ),
              ),
              Switch(
                value: _isOnline,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: (val) => setState(() => _isOnline = val),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: tr.profile,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status and Vehicle Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isOnline ? AppColors.warmCream : AppColors.borderLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isOnline ? AppColors.primaryGreen : AppColors.mutedGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.two_wheeler, color: _isOnline ? AppColors.primaryGreen : AppColors.mutedGrey),
                      const SizedBox(width: 8),
                      Text(
                        currentUser?.transportType ?? 'Motorcycle Dispatcher',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isOnline ? AppColors.charcoal : AppColors.mutedGrey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Active: ${activeTasks.length} / Max 2',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: activeTasks.isNotEmpty ? AppColors.orange : AppColors.mutedGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (!_isOnline)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.mutedGrey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.mutedGrey.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: AppColors.mutedGrey, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You are offline. Switch availability toggle to Online to accept live dispatch tasks.',
                        style: TextStyle(fontSize: 12, color: AppColors.charcoal),
                      ),
                    ),
                  ],
                ),
              ),

            // Active Task View (if accepted)
            if (activeTasks.isNotEmpty) ...[
              Text(
                'YOUR ACTIVE DISPATCH (${activeTasks.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 10),
              ...activeTasks.map((task) {
                final dateFormat = DateFormat('hh:mm a');
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.primaryGreen, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: task.status == DonationStatus.assigned
                                    ? AppColors.warningOrange.withValues(alpha: 0.15)
                                    : AppColors.statusInTransitBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.status == DonationStatus.assigned
                                    ? 'PROCEED TO PICKUP'
                                    : 'IN TRANSIT TO SHELTER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: task.status == DonationStatus.assigned
                                      ? AppColors.warningOrange
                                      : AppColors.statusInTransitText,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 14, color: AppColors.errorRed),
                                const SizedBox(width: 4),
                                Text(
                                  'Collect by ${dateFormat.format(task.pickupDeadline)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.errorRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          task.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${task.quantity.toStringAsFixed(0)} ${task.unit} • Destination: ${task.claimedByNgoName ?? "Shelter"}',
                          style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Private Donor Address Unlocked
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.pickupAddress,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  const Text(
                                    'Pickup Address (Unlocked for this dispatch)',
                                    style: TextStyle(fontSize: 11, color: AppColors.primaryGreen),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (task.donorPhone != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: AppColors.primaryGreen, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Donor: ${task.donorName} (${task.donorPhone})',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Open Live Mission & Navigation
                        FBButton.rider(
                          label: 'OPEN LIVE MISSION & GPS',
                          icon: Icons.navigation_outlined,
                          onPressed: () => context.push('/volunteer/mission/${task.id}'),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () => context.push('/donation-detail/${task.id}'),
                            child: const Text('View Full Donation Specs', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // Open Task Feed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Dispatches (${availableTasks.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (availableTasks.isEmpty)
              const FBEmptyState(
                title: 'No Pending Pickups',
                description: 'All current NGO claims have active couriers or there are no new claims.',
                icon: Icons.two_wheeler_outlined,
              )
            else
              ...availableTasks.map((task) {
                final dateFormat = DateFormat('hh:mm a');
                final hasMaxDispatches = activeTasks.length >= 2;
                final aiMatch = AIService().calculateMatch(donation: task, distanceKm: task.estimatedDistanceKm);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => VolunteerTaskDetailSheet.show(context, task: task, isOnline: _isOnline),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.statusAvailableBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      task.isFood ? '🍛 FOOD RESCUE' : '👕 CLOTHES DISPATCH',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.statusAvailableText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.auto_awesome, size: 11, color: AppColors.primaryGreen),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${aiMatch.matchScorePercent}% Match',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.deepGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Collect by ${dateFormat.format(task.pickupDeadline)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.errorRed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Route: ${task.city} ──► ${task.claimedByNgoName ?? "NGO Shelter"} (${task.estimatedDistanceKm} km)',
                            style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.isFood
                                ? 'Handling: ${(task.storageCondition ?? "ambient").toUpperCase()} • ${task.isVeg ? "Veg" : "Non-Veg"}'
                                : 'Handling: ${task.clothingCategory ?? "Clean Clothing"} • ${task.targetSize ?? "All Sizes"}',
                            style: TextStyle(fontSize: 12, color: AppColors.deepGreen.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 14),
                          FBButton.rider(
                            label: hasMaxDispatches ? 'MAX 2 DISPATCHES REACHED' : 'REVIEW & ACCEPT TASK',
                            icon: Icons.checklist_rtl_outlined,
                            onPressed: () => VolunteerTaskDetailSheet.show(
                              context,
                              task: task,
                              isOnline: _isOnline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24),

            // Lifetime Stats Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Completed', '${completedTasks.length} missions', Icons.task_alt),
                  _statItem('Meals Rescued', '${completedTasks.fold<int>(0, (s, d) => s + d.quantity.toInt())}', Icons.restaurant),
                  _statItem('Rating', '5.0 ★', Icons.star),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.charcoal)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey)),
      ],
    );
  }
}
