import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  bool _isOnline = true;
  bool _hasActiveTask = false;
  String _taskState = 'assigned'; // 'assigned' -> 'picked_up' -> 'completed'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Dispatch'),
        actions: [
          Row(
            children: [
              Text(
                _isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 13,
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
                color: _isOnline ? AppColors.warmCream : AppColors.borderLight.withOpacity(0.5),
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
                        'Motorcycle (125cc)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isOnline ? AppColors.charcoal : AppColors.mutedGrey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Active: ${_hasActiveTask ? "1" : "0"} / Max 2',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _hasActiveTask ? AppColors.orange : AppColors.mutedGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Task View (if accepted)
            if (_hasActiveTask) ...[
              Text(
                'YOUR ACTIVE DISPATCH',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 10),
              Card(
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
                              color: AppColors.statusInTransitBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _taskState == 'assigned' ? 'PROCEED TO PICKUP' : 'IN TRANSIT TO SHELTER',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.statusInTransitText,
                              ),
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 14, color: AppColors.errorRed),
                              SizedBox(width: 4),
                              Text(
                                '32m left',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.errorRed),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '35 kg Cooked Banquet Meals (3 Insulated Crates)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Unlocked Private Address & Phone
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Service Gate 3, Royal Feast Banquet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text('Link Road, Andheri West (Unlocked for you)', style: TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.phone, color: AppColors.primaryGreen, size: 18),
                          SizedBox(width: 8),
                          Text('Donor: Ramesh Sharma (+91 98765 43210)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Rider Mode Big Action Buttons
                      if (_taskState == 'assigned') ...[
                        FBButton.rider(
                          label: 'CONFIRM PHYSICAL PICKUP',
                          icon: Icons.check_circle_outline,
                          onPressed: () {
                            setState(() => _taskState = 'picked_up');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pickup verified! In-transit timer active.'),
                                backgroundColor: AppColors.primaryGreen,
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        FBButton.rider(
                          label: 'CONFIRM HANDOVER TO NGO',
                          icon: Icons.done_all,
                          onPressed: () {
                            setState(() {
                              _hasActiveTask = false;
                              _taskState = 'assigned';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Dispatch completed! Thank you for your service.'),
                                backgroundColor: AppColors.deepGreen,
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _hasActiveTask = false;
                            _taskState = 'assigned';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task surrendered for immediate re-dispatch.'),
                              backgroundColor: AppColors.orange,
                            ),
                          );
                        },
                        child: const Text('Emergency Surrender (Vehicle Breakdown)', style: TextStyle(color: AppColors.errorRed, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Open Task Feed
            Text(
              'Available Dispatches Near You',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Open Task 1
            _OpenTaskCard(
              title: '35 kg Hot Meals (Banquet to Annapoorna)',
              route: 'Andheri West ──► Thane (4.2 km total)',
              vehicleTag: '🛵 TWO-WHEELER COMPATIBLE (12 kg)',
              deadlineText: '35 mins remaining',
              isTwoWheelerFriendly: true,
              onAccept: () {
                setState(() {
                  _hasActiveTask = true;
                  _taskState = 'assigned';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task locked exclusively to you! Safe riding.'),
                    backgroundColor: AppColors.deepGreen,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Open Task 2
            _OpenTaskCard(
              title: '4 Large Crates of Apples & Bread (80 kg)',
              route: 'Dadar Market ──► Sion Shelter (6.1 km)',
              vehicleTag: '🚗 FOUR-WHEELER / VAN REQUIRED',
              deadlineText: '2.5 hrs remaining',
              isTwoWheelerFriendly: false,
              onAccept: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This cargo requires a 4-wheeler or van.'),
                    backgroundColor: AppColors.orange,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenTaskCard extends StatelessWidget {
  final String title;
  final String route;
  final String vehicleTag;
  final String deadlineText;
  final bool isTwoWheelerFriendly;
  final VoidCallback onAccept;

  const _OpenTaskCard({
    required this.title,
    required this.route,
    required this.vehicleTag,
    required this.deadlineText,
    required this.isTwoWheelerFriendly,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTwoWheelerFriendly ? AppColors.statusAvailableBg : AppColors.statusInTransitBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    vehicleTag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isTwoWheelerFriendly ? AppColors.statusAvailableText : AppColors.statusInTransitText,
                    ),
                  ),
                ),
                Text(
                  deadlineText,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.errorRed),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.charcoal),
            ),
            const SizedBox(height: 6),
            Text(
              route,
              style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey),
            ),
            const SizedBox(height: 16),
            FBButton.rider(
              label: isTwoWheelerFriendly ? 'ACCEPT DISPATCH TASK' : 'VIEW 4-WHEELER TASK',
              icon: Icons.flash_on,
              onPressed: onAccept,
            ),
          ],
        ),
      ),
    );
  }
}
