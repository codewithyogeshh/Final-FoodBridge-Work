import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            const Row(
              children: [
                Expanded(child: _AdminStatTile(count: '4', label: 'Pending NGOs', color: AppColors.orange)),
                SizedBox(width: 8),
                Expanded(child: _AdminStatTile(count: '18', label: 'Active Rescues', color: AppColors.primaryGreen)),
                SizedBox(width: 8),
                Expanded(child: _AdminStatTile(count: '0', label: 'Incidents', color: AppColors.deepGreen)),
              ],
            ),
            const SizedBox(height: 24),

            // Pending NGO Verification Queue
            Text(
              'Pending NGO Verifications (1)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Helping Hands Shelter',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.statusInTransitBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Pending Review', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.statusInTransitText)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Reg No: MH/2023/008129 • Darpan ID Verified', style: TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppColors.errorRed, size: 20),
                        const SizedBox(width: 6),
                        const Text('12A_80G_Certificate.pdf', style: TextStyle(fontSize: 13, decoration: TextDecoration.underline)),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Preview'),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Helping Hands Shelter has been approved!'),
                                  backgroundColor: AppColors.deepGreen,
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
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Live Audit Log Stream
            Text(
              'Recent System Audit Logs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _auditRow('DONATION_CLAIMED', 'Annapoorna claimed 35kg from Royal Feast', '2 mins ago'),
            _auditRow('VOLUNTEER_ASSIGNED', 'Rahul P. accepted Dispatch #FB-804', '4 mins ago'),
            _auditRow('DONATION_CREATED', 'Royal Feast posted 35kg Cooked Food', '15 mins ago'),
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
                Text(action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.charcoal)),
                Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

