import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../donations/presentation/donation_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final List<Map<String, String>> _pendingNgos = [
    {
      'id': 'ngo-app-1',
      'name': 'Seva Deep Foundation',
      'regNo': 'MH/2023/008129',
      'darpanId': 'MH/2023/DARPAN-4412',
      'docName': '12A_80G_Certificate.pdf',
    },
    {
      'id': 'ngo-app-2',
      'name': 'Pune City Hunger Relief',
      'regNo': 'MH/2021/004921',
      'darpanId': 'MH/2021/DARPAN-8910',
      'docName': 'Trust_Deed_FCRA.pdf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final donationProvider = context.watch<DonationProvider>();
    final activeCount = donationProvider.activeListingsCount;
    final mealsCount = donationProvider.totalMealsRescued.toStringAsFixed(0);
    final clothesCount = donationProvider.totalClothingItemsRedistributed.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
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
            // Admin Metric Row
            Row(
              children: [
                Expanded(
                  child: _AdminStatTile(
                    count: _pendingNgos.length.toString(),
                    label: 'Pending NGOs',
                    color: AppColors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AdminStatTile(
                    count: activeCount.toString(),
                    label: 'Active Listings',
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AdminStatTile(
                    count: mealsCount,
                    label: 'Meals Rescued',
                    color: AppColors.deepGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AdminStatTile(
                    count: clothesCount,
                    label: 'Clothes Given',
                    color: AppColors.warningOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pending NGO Verification Queue
            Text(
              'Pending NGO Verifications (${_pendingNgos.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            if (_pendingNgos.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warmCream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: AppColors.primaryGreen),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All NGO registration applications have been reviewed!',
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepGreen),
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._pendingNgos.map((ngo) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ngo['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.warningOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Pending Review',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warningOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Darpan: ${ngo['darpanId']} • Reg: ${ngo['regNo']}',
                          style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: AppColors.errorRed, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              ngo['docName']!,
                              style: const TextStyle(
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Viewing certificate: ${ngo['docName']}')),
                                );
                              },
                              child: const Text('Preview PDF'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FBButton(
                                label: 'Approve NGO',
                                height: 44,
                                onPressed: () {
                                  setState(() {
                                    _pendingNgos.removeWhere((item) => item['id'] == ngo['id']);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${ngo['name']} approved and verified!'),
                                      backgroundColor: AppColors.primaryGreen,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FBButton(
                                label: 'Reject',
                                variant: FBButtonVariant.danger,
                                height: 44,
                                onPressed: () {
                                  setState(() {
                                    _pendingNgos.removeWhere((item) => item['id'] == ngo['id']);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Application rejected for ${ngo['name']}.'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 28),

            // Live Audit Log Stream
            Text(
              'Recent System Audit Logs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _auditRow('DONATION_CLAIMED', 'Asha Shelter claimed 40 Chapati & Paneer Combos', 'Just now'),
            _auditRow('VOLUNTEER_ASSIGNED', 'Rohit Kulkarni accepted Dispatch #dn-105', '12 mins ago'),
            _auditRow('DONATION_CREATED', 'The Green Leaf Bistro listed 50 Veg Biryani Meals', '45 mins ago'),
            _auditRow('DELIVERY_CONFIRMED', 'Rohit K. completed delivery of 50 School Uniforms', '1 hour ago'),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _auditRow(String action, String detail, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 10, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey)),
        ],
      ),
    );
  }
}

class _AdminStatTile extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const _AdminStatTile({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.mutedGrey, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
