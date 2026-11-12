import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../../authentication/domain/models/app_user.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../donations/presentation/donation_provider.dart';
import '../domain/models/complaint.dart';
import 'admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSuspendUserDialog(BuildContext context, ManagedUser user) {
    final reasonController = TextEditingController();
    final adminProvider = context.read<AdminProvider>();
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Suspend ${user.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to suspend account: ${user.email}?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Suspension Reason',
                hintText: 'e.g. Non-compliance with safety charter',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white),
            onPressed: () async {
              final reason = reasonController.text.trim().isNotEmpty
                  ? reasonController.text.trim()
                  : 'Administrative suspension';
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await adminProvider.suspendUser(
                userId: user.id,
                reason: reason,
                adminId: authProvider.user?.id ?? 'usr-admin-001',
              );
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Account ${user.email} suspended.')),
                );
              }
            },
            child: const Text('Confirm Suspend'),
          ),
        ],
      ),
    );
  }

  void _showResolveComplaintDialog(BuildContext context, Complaint complaint) {
    final notesController = TextEditingController();
    final adminProvider = context.read<AdminProvider>();
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Resolve Complaint #${complaint.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${complaint.category}'),
            const SizedBox(height: 4),
            Text('Issue: ${complaint.description}', style: const TextStyle(fontSize: 13, color: AppColors.mutedGrey)),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Resolution Action / Notes',
                hintText: 'e.g. Warned donor and issued packaging guidance',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () async {
              final notes = notesController.text.trim().isNotEmpty
                  ? notesController.text.trim()
                  : 'Resolved by administrator inspection';
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await adminProvider.resolveComplaint(
                complaintId: complaint.id,
                resolutionNotes: notes,
                adminId: authProvider.user?.id ?? 'usr-admin-001',
              );
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Complaint marked as resolved.')),
                );
              }
            },
            child: const Text('Resolve Complaint'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final donationProvider = context.watch<DonationProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final authProvider = context.watch<AuthProvider>();
    final analytics = adminProvider.computeAnalytics(donationProvider.allDonations);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.mutedGrey,
          indicatorColor: AppColors.primaryGreen,
          tabs: [
            Tab(text: 'Overview & Analytics (${analytics['totalDonations']})'),
            Tab(text: 'NGO Approvals (${adminProvider.pendingNgoCount})'),
            Tab(text: 'Users (${adminProvider.managedUsers.length})'),
            Tab(text: 'Complaints (${adminProvider.openComplaintsCount})'),
            const Tab(text: 'Audit Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Overview & Analytics Tab
          _buildAnalyticsTab(context, analytics, donationProvider),

          // 2. NGO Verification Approvals Tab
          _buildNgoApprovalsTab(context, adminProvider, authProvider),

          // 3. User Management & Suspension Tab
          _buildUserManagementTab(context, adminProvider, authProvider),

          // 4. Complaint Management Tab
          _buildComplaintsTab(context, adminProvider),

          // 5. Audit Log Trail Tab
          _buildAuditLogsTab(context, adminProvider),
        ],
      ),
    );
  }

  // 1. Analytics & Overview
  Widget _buildAnalyticsTab(
    BuildContext context,
    Map<String, dynamic> analytics,
    DonationProvider donationProvider,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Verified Database Metrics Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.deepGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All analytics are computed dynamically from real database records (Zero fabricated statistics).',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.deepGreen),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4 Primary KPI Tiles
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Total Listings',
                count: '${analytics['totalDonations']}',
                icon: Icons.inventory_2,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Food Rescues',
                count: '${analytics['foodDonations']}',
                icon: Icons.soup_kitchen,
                color: AppColors.deepGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Clothing Items',
                count: '${analytics['clothingDonations']}',
                icon: Icons.checkroom,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Deliveries Made',
                count: '${analytics['successfulDeliveries']}',
                icon: Icons.task_alt,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Verified NGOs',
                count: '${analytics['activeNgos']}',
                icon: Icons.domain,
                color: AppColors.deepGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Active Riders',
                count: '${analytics['activeVolunteers']}',
                icon: Icons.two_wheeler,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Live Donation Monitoring
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Live Donation Lifecycle Monitoring',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${donationProvider.allDonations.length} items',
              style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...donationProvider.allDonations.map((d) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: d.isFood ? AppColors.primaryGreen.withValues(alpha: 0.12) : AppColors.orange.withValues(alpha: 0.12),
                  child: Icon(d.isFood ? Icons.restaurant : Icons.checkroom, size: 20, color: d.isFood ? AppColors.primaryGreen : AppColors.orange),
                ),
                title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Donor: ${d.donorName} • Status: ${d.status.displayName}', style: const TextStyle(fontSize: 12)),
                trailing: Chip(
                  label: Text(d.status.displayName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.warmCream,
                ),
                onTap: () => context.push('/donation-detail/${d.id}'),
              ),
            )),
      ],
    );
  }

  // 2. NGO Approvals Tab
  Widget _buildNgoApprovalsTab(
    BuildContext context,
    AdminProvider adminProvider,
    AuthProvider authProvider,
  ) {
    final list = adminProvider.pendingNgos;
    if (list.isEmpty) {
      return const FBEmptyState(
        icon: Icons.verified_user_outlined,
        title: 'NGO Verification Queue Clear',
        description: 'All submitted NGO registration credentials and Darpan/80G documents have been evaluated.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final ngo = list[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ngo.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warningOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Pending Verification', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warningOrange)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Darpan: ${ngo.darpanId} • Reg: ${ngo.regNo}', style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
                Text('Contact: ${ngo.contactPerson} (${ngo.phone})', style: const TextStyle(fontSize: 12, color: AppColors.charcoal)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: AppColors.errorRed, size: 20),
                    const SizedBox(width: 8),
                    Text(ngo.documentName, style: const TextStyle(fontSize: 12, decoration: TextDecoration.underline)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FBButton(
                        label: 'Approve NGO',
                        height: 44,
                        onPressed: () => adminProvider.approveNgo(
                          ngoId: ngo.id,
                          adminId: authProvider.user?.id ?? 'usr-admin-001',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FBButton(
                        label: 'Reject',
                        variant: FBButtonVariant.danger,
                        height: 44,
                        onPressed: () => adminProvider.rejectNgo(
                          ngoId: ngo.id,
                          reason: 'Incomplete tax-exempt certificate',
                          adminId: authProvider.user?.id ?? 'usr-admin-001',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. User Management Tab
  Widget _buildUserManagementTab(
    BuildContext context,
    AdminProvider adminProvider,
    AuthProvider authProvider,
  ) {
    final users = adminProvider.managedUsers;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: users.length,
      itemBuilder: (context, idx) {
        final u = users[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: u.isSuspended ? AppColors.errorRed.withValues(alpha: 0.12) : AppColors.primaryGreen.withValues(alpha: 0.12),
                  child: Icon(
                    u.role == UserRole.donor
                        ? Icons.soup_kitchen
                        : u.role == UserRole.ngo
                            ? Icons.domain
                            : Icons.two_wheeler,
                    color: u.isSuspended ? AppColors.errorRed : AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 8),
                          if (u.isSuspended)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.errorRed, borderRadius: BorderRadius.circular(4)),
                              child: const Text('SUSPENDED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${u.email} • Role: ${u.role.displayName}', style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
                      if (u.isSuspended && u.suspensionReason != null) ...[
                        const SizedBox(height: 4),
                        Text('Reason: ${u.suspensionReason!}', style: const TextStyle(fontSize: 11, color: AppColors.errorRed, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
                if (!u.isSuspended)
                  TextButton(
                    onPressed: () => _showSuspendUserDialog(context, u),
                    child: const Text('Suspend', style: TextStyle(color: AppColors.errorRed)),
                  )
                else
                  TextButton(
                    onPressed: () => adminProvider.reactivateUser(
                      userId: u.id,
                      adminId: authProvider.user?.id ?? 'usr-admin-001',
                    ),
                    child: const Text('Reactivate', style: TextStyle(color: AppColors.primaryGreen)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. Complaints Tab
  Widget _buildComplaintsTab(BuildContext context, AdminProvider adminProvider) {
    final list = adminProvider.complaints;
    if (list.isEmpty) {
      return const FBEmptyState(
        icon: Icons.thumb_up_alt_outlined,
        title: 'Zero Open Complaints',
        description: 'No active complaints or safety disputes are awaiting moderation.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final c = list[idx];
        final isOpen = c.status == ComplaintStatus.open;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Complaint #${c.id} (${c.category})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Chip(
                      label: Text(c.status.displayName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: isOpen ? AppColors.warningOrange.withValues(alpha: 0.15) : AppColors.primaryGreen.withValues(alpha: 0.15),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Filed by: ${c.reporterName} against ${c.respondentName}', style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey)),
                const SizedBox(height: 6),
                Text(c.description, style: const TextStyle(fontSize: 13, color: AppColors.charcoal)),
                if (c.resolutionNotes != null) ...[
                  const SizedBox(height: 8),
                  Text('Resolution: ${c.resolutionNotes!}', style: const TextStyle(fontSize: 12, color: AppColors.deepGreen, fontStyle: FontStyle.italic)),
                ],
                if (isOpen) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showResolveComplaintDialog(context, c),
                          child: const Text('Resolve Issue'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => adminProvider.dismissComplaint(
                          complaintId: c.id,
                          reason: 'No violation found',
                          adminId: 'usr-admin-001',
                        ),
                        child: const Text('Dismiss', style: TextStyle(color: AppColors.mutedGrey)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // 5. Audit Logs Tab
  Widget _buildAuditLogsTab(BuildContext context, AdminProvider adminProvider) {
    final logs = adminProvider.auditLogs;
    final dateFormat = DateFormat('hh:mm a, d MMM yyyy');

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: logs.length,
      itemBuilder: (context, idx) {
        final log = logs[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.history_toggle_off, color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.charcoal)),
                          Text(dateFormat.format(log.timestamp), style: const TextStyle(fontSize: 10, color: AppColors.mutedGrey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(log.details, style: const TextStyle(fontSize: 12, color: AppColors.charcoal)),
                      const SizedBox(height: 4),
                      Text('Actor: ${log.actorId} (${log.actorRole}) • Target: ${log.targetEntity} • IP: ${log.ipHash}', style: const TextStyle(fontSize: 10, color: AppColors.mutedGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                count,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
