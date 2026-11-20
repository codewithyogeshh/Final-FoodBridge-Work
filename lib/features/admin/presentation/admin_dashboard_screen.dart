import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/avatar_image_helper.dart';
import '../../../core/widgets/exit_confirmation_dialog.dart';
import '../../../core/widgets/fb_appearance_selector.dart';
import '../../../core/widgets/fb_button.dart';
import '../../../core/widgets/fb_empty_state.dart';
import '../../authentication/domain/models/app_user.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../authentication/presentation/widgets/terms_and_conditions_modal.dart';
import '../../donations/domain/models/donation.dart';
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
  String _donationFilter = 'all'; // 'all', 'available', 'intransit', 'delivered'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TermsAndConditionsModal.showIfNeeded(context);
      context.read<AdminProvider>().syncUsersWithAuth();
      context.read<DonationProvider>().syncWithUserProfiles();
    });
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
        content: SingleChildScrollView(
          child: Column(
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

  void _showDocumentInspectionDialog(BuildContext context, PendingNgoApplication ngo) {
    final adminProvider = context.read<AdminProvider>();
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user, color: AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'पडताळणी कागदपत्रे (Verification Docs)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                ngo.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepGreen),
              ),
              const SizedBox(height: 4),
              Text(
                'दर्पण आयडी: ${ngo.darpanId} • नोंदणी क्र: ${ngo.regNo}',
                style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),

              // Certificate Preview Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppColors.errorRed, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ngo.documentName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const Text(
                                'Govt Verified 12A/80G & Trust Deed Format',
                                style: TextStyle(fontSize: 11, color: AppColors.mutedGrey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'VALID',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text('नोंदणीकृत तपशील (Registered Details):', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _docDetailRow('संस्था नाव:', ngo.name),
                    _docDetailRow('संपर्क व्यक्ती:', ngo.contactPerson),
                    _docDetailRow('फोन नंबर:', ngo.phone),
                    _docDetailRow('ईमेल:', ngo.email ?? 'ngo@foodbridge.org'),
                    _docDetailRow('दर्पण नोंदणी:', ngo.darpanId),
                    _docDetailRow('शासकीय नोंदणी क्र:', ngo.regNo),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.deepGreen),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'मंजूर (Approve) केल्यानंतर संस्थेला थेट सिस्टीम व इन-ॲप नोटीफिकेशन पाठवले जाईल.',
                        style: TextStyle(fontSize: 11, color: AppColors.deepGreen),
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('बंद करा (Close)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final success = await adminProvider.approveNgo(
                ngoId: ngo.id,
                adminId: authProvider.user?.id ?? 'usr-admin-001',
              );
              if (mounted && success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('संस्था "${ngo.name}" पडताळणी मंजूर! NGO ला नोटीफिकेशन पाठवले आहे.'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              }
            },
            child: const Text('मंजूर करा (Approve & Notify)'),
          ),
        ],
      ),
    );
  }

  Widget _docDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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
        content: SingleChildScrollView(
          child: Column(
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
    final tr = context.tr;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final donationProvider = context.watch<DonationProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final authProvider = context.watch<AuthProvider>();
    final analytics = adminProvider.computeAnalytics(donationProvider.allDonations);

    return FoodBridgeExitScope(
      child: Scaffold(
      appBar: AppBar(
        title: Text(tr.adminConsole),
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
            icon: const Icon(Icons.notifications_outlined),
            tooltip: tr.notifications,
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: tr.profile,
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
            Tab(text: '${tr.get("overview")} (${analytics['totalDonations']})'),
            Tab(text: '${tr.get("verifications")} (${adminProvider.pendingNgoCount})'),
            Tab(text: '${tr.get("user_management")} (${adminProvider.managedUsers.length})'),
            Tab(text: '${tr.get("complaints")} (${adminProvider.openComplaintsCount})'),
            Tab(text: tr.get("audit_logs")),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Overview & Analytics Tab
          _buildAnalyticsTab(context, analytics, donationProvider, adminProvider, authProvider),

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
    ),
  );
  }

  // 1. Analytics & Overview
  Widget _buildAnalyticsTab(
    BuildContext context,
    Map<String, dynamic> analytics,
    DonationProvider donationProvider,
    AdminProvider adminProvider,
    AuthProvider authProvider,
  ) {
    final int total = donationProvider.allDonations.length;
    final int available = donationProvider.totalAvailableCount;
    final int inTransit = donationProvider.totalInTransitCount +
        donationProvider.totalClaimedCount;
    final int delivered = donationProvider.totalDeliveredCount;
    final double mealsRescued =
        (analytics['totalMealsRescued'] as num?)?.toDouble() ?? 0.0;
    final int clothesCount = analytics['totalClothingItems'] as int? ?? 0;

    final displayedDonations = donationProvider.allDonations.where((d) {
      if (_donationFilter == 'available') {
        return !d.isExpired &&
            (d.status == DonationStatus.available || d.status == DonationStatus.listed);
      }
      if (_donationFilter == 'intransit') {
        if (d.isDelivered || d.deliveredAt != null || d.isExpired) return false;
        return d.status == DonationStatus.accepted ||
            d.status == DonationStatus.claimed ||
            d.status == DonationStatus.assigned ||
            d.status == DonationStatus.assignedForPickup ||
            d.status == DonationStatus.pickedUp;
      }
      if (_donationFilter == 'delivered') {
        return d.isDelivered ||
            d.deliveredAt != null ||
            d.status == DonationStatus.delivered ||
            d.status == DonationStatus.deliveredToNgo ||
            d.status == DonationStatus.distributed ||
            d.status == DonationStatus.completed;
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => donationProvider.refreshDonations(),
      color: AppColors.primaryGreen,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
        // Top Welcome Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back, ${authProvider.user?.fullName.isNotEmpty == true ? authProvider.user!.fullName : "Admin"}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Real-time monitoring of donations, shelters, volunteers, and deliveries.",
                    style: TextStyle(fontSize: 13, color: AppColors.mutedGrey),
                  ),
                ],
              ),
            ),
            if (authProvider.user != null) ...[
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                backgroundImage: AvatarImageHelper.resolve(authProvider.user?.avatarUrl),
                child: AvatarImageHelper.resolve(authProvider.user?.avatarUrl) == null
                    ? Text(
                        authProvider.user!.fullName.trim().isNotEmpty
                            ? authProvider.user!.fullName.trim().substring(0, 1).toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: AppColors.deepGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),

        // Live Network Sync Banner
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Multi-Device Realtime Sync Active • All nodes connected',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepGreen,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4 Primary KPI Tiles - Real Empirical Data
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Total Donations',
                count: '$total',
                trend: 'एकूण नोंदवलेली दाने',
                icon: Icons.inventory_2_outlined,
                color: AppColors.deepGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Available (उपलब्ध)',
                count: '$available',
                trend: 'शेल्टर क्लेमसाठी उपलब्ध',
                icon: Icons.storefront_outlined,
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
                label: 'In Transit (वाटेत)',
                count: '$inTransit',
                trend: 'व्हॉलंटियर पिकअप/डिलिव्हरी',
                icon: Icons.local_shipping_outlined,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Distributed (वाटप)',
                count: '$delivered',
                trend: 'यशस्वी वाटप पूर्ण ✓',
                icon: Icons.volunteer_activism_outlined,
                color: const Color(0xFF27AE60),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Live Impact Summary Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F4D2E), Color(0xFF1E824C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Impact Summary (थेट परिणाम)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Rescued Food: ${mealsRescued.toStringAsFixed(0)} meals redistributed\n'
                      '• Warm Wear / Clothes: $clothesCount pieces distributed\n'
                      '• Registered Users: ${adminProvider.managedUsers.length} • Shelters: ${analytics['activeNgos'] ?? 0}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.volunteer_activism, color: Colors.white, size: 40),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Structured Donation Lifecycle Monitoring
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Donations Tracker (सर्व दाने व स्थिती)',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepGreen),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${displayedDonations.length} of $total',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedGrey,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDonationFilterChip('all', 'All ($total)'),
              const SizedBox(width: 8),
              _buildDonationFilterChip('available', 'Available ($available)'),
              const SizedBox(width: 8),
              _buildDonationFilterChip('intransit', 'In Transit ($inTransit)'),
              const SizedBox(width: 8),
              _buildDonationFilterChip('delivered', 'Distributed ($delivered)'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Structured List or Empty State
        if (displayedDonations.isEmpty)
          const FBEmptyState(
            title: 'No Donations Found',
            description:
                'Donations matching this filter will appear here in real time as users interact with the platform.',
            icon: Icons.inventory_2_outlined,
          )
        else
          ...displayedDonations.map((d) => _buildAdminDonationCard(context, d, adminProvider)),
      ],
    ),
  );
}

  Widget _buildDonationFilterChip(String key, String label) {
    final isSelected = _donationFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _donationFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.charcoal,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDonationCard(BuildContext context, Donation d, AdminProvider adminProvider) {
    Color badgeColor;
    Color badgeTextColor;
    String statusLabel = d.status.displayName;

    if (d.isDelivered ||
        d.deliveredAt != null ||
        d.status == DonationStatus.delivered ||
        d.status == DonationStatus.deliveredToNgo ||
        d.status == DonationStatus.distributed ||
        d.status == DonationStatus.completed) {
      badgeColor = const Color(0xFF27AE60).withOpacity(0.12);
      badgeTextColor = const Color(0xFF27AE60);
      statusLabel = 'Delivered & Distributed / वितरण पूर्ण ✓';
    } else if (d.isExpired) {
      badgeColor = AppColors.errorRed.withOpacity(0.12);
      badgeTextColor = AppColors.errorRed;
      statusLabel = 'Expired / कालबाह्य';
    } else if (d.status == DonationStatus.available ||
        d.status == DonationStatus.listed) {
      badgeColor = AppColors.primaryGreen.withOpacity(0.12);
      badgeTextColor = AppColors.primaryGreen;
      statusLabel = 'Available / उपलब्ध';
    } else if (d.status == DonationStatus.accepted ||
        d.status == DonationStatus.claimed) {
      badgeColor = AppColors.orange.withOpacity(0.12);
      badgeTextColor = AppColors.orange;
      statusLabel = 'Claimed / क्लेम झाले';
    } else if (d.status == DonationStatus.assigned ||
        d.status == DonationStatus.assignedForPickup ||
        d.status == DonationStatus.pickedUp) {
      badgeColor = const Color(0xFF2980B9).withOpacity(0.12);
      badgeTextColor = const Color(0xFF2980B9);
      statusLabel = d.status == DonationStatus.pickedUp
          ? 'In Transit / वाटेत'
          : 'Volunteer Assigned / नेमले';
    } else {
      badgeColor = AppColors.mutedGrey.withOpacity(0.12);
      badgeTextColor = AppColors.mutedGrey;
    }

    final isFood = d.isFood;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/donation-detail/${d.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Type Icon, Title & Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isFood
                          ? AppColors.primaryGreen.withOpacity(0.12)
                          : AppColors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isFood ? Icons.restaurant : Icons.checkroom,
                      color:
                          isFood ? AppColors.primaryGreen : AppColors.orange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.quantity.toStringAsFixed(0)} ${d.unit} • ${isFood ? (d.isVeg ? "Veg 🟢" : "Non-Veg 🔴") : "Clean Wear"}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedGrey,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Details Grid: Donor & Location
              Builder(
                builder: (context) {
                  final donorUser = adminProvider.managedUsers.where((u) {
                    if (d.donorId.isNotEmpty && u.id == d.donorId) return true;
                    if (u.email.toLowerCase().trim() == 'donor@foodbridge.org' && d.donorId == 'usr-donor-101') return true;
                    return false;
                  }).firstOrNull;
                  final displayDonorName = donorUser?.fullName.trim().isNotEmpty == true
                      ? donorUser!.fullName.trim()
                      : d.donorName;

                  return Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 15, color: AppColors.mutedGrey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Donor: $displayDonorName${d.donorPhone != null ? " (${d.donorPhone})" : ""}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 15, color: AppColors.mutedGrey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${d.pickupAddress}, ${d.city}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.mutedGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Shelter & Volunteer details with unambiguous claim ownership
              Builder(
                builder: (context) {
                  final ngoUser = adminProvider.managedUsers.where((u) {
                    if (d.claimedByNgoId != null && u.id == d.claimedByNgoId) return true;
                    if (u.email.toLowerCase().trim() == 'ngo@foodbridge.org' && d.claimedByNgoId == 'usr-ngo-202') return true;
                    return false;
                  }).firstOrNull;
                  final displayNgoName = ngoUser?.fullName.trim().isNotEmpty == true
                      ? ngoUser!.fullName.trim()
                      : d.claimedByNgoName;

                  final volUser = adminProvider.managedUsers.where((u) {
                    if (d.assignedVolunteerId != null && u.id == d.assignedVolunteerId) return true;
                    if (u.email.toLowerCase().trim() == 'volunteer@foodbridge.org') {
                      if (d.assignedVolunteerId == 'usr-vol-303' ||
                          d.assignedVolunteerName == 'Rohit Kulkarni' ||
                          d.assignedVolunteerName == 'Yogesh Chavan') {
                        return true;
                      }
                    }
                    return false;
                  }).firstOrNull;

                  final hasVol = (d.assignedVolunteerName != null && d.assignedVolunteerName!.trim().isNotEmpty) ||
                      (d.assignedVolunteerId != null && d.assignedVolunteerId!.trim().isNotEmpty);

                  final displayVolName = hasVol
                      ? (volUser?.fullName.trim().isNotEmpty == true
                          ? volUser!.fullName.trim()
                          : (d.assignedVolunteerName == 'Rohit Kulkarni'
                              ? (volUser?.fullName ?? 'Volunteer')
                              : (d.assignedVolunteerName ?? 'Volunteer')))
                      : 'Unassigned';

                  return Row(
                    children: [
                      Icon(
                        displayNgoName != null
                            ? Icons.verified
                            : Icons.hourglass_empty,
                        size: 15,
                        color: displayNgoName != null
                            ? AppColors.primaryGreen
                            : AppColors.orange,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          displayNgoName != null
                              ? 'Shelter: $displayNgoName ने स्वीकारले ✓'
                              : 'Shelter: Not yet accepted (कोणत्याही शेल्टरने अजून स्वीकारलेले नाही)',
                          style: TextStyle(
                            fontSize: 12,
                            color: displayNgoName != null
                                ? AppColors.charcoal
                                : AppColors.orange,
                            fontWeight: displayNgoName != null
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.two_wheeler_outlined,
                          size: 15,
                          color: hasVol
                              ? AppColors.orange
                              : AppColors.mutedGrey),
                      const SizedBox(width: 4),
                      Text(
                        hasVol ? 'Vol: $displayVolName' : 'Vol: Unassigned',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: hasVol
                                ? AppColors.orange
                                : AppColors.mutedGrey),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),

              // Admin Audit Bar: OTPs & Deadline
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warmCream.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Pickup OTP: ${d.pickupOtp} • Delivery OTP: ${d.deliveryOtp}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepGreen),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM, hh:mm a').format(d.pickupDeadline),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.mutedGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                    Expanded(
                      child: Text(
                        ngo.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                InkWell(
                  onTap: () => _showDocumentInspectionDialog(context, ngo),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: AppColors.errorRed, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ngo.documentName,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                'टॅप करून कागदपत्रे उघडा व तपासा (Tap to Inspect)',
                                style: TextStyle(fontSize: 10.5, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility_outlined, size: 14, color: AppColors.primaryGreen),
                              SizedBox(width: 4),
                              Text('तपासा', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FBButton(
                        label: 'Approve NGO',
                        height: 44,
                        onPressed: () async {
                          final success = await adminProvider.approveNgo(
                            ngoId: ngo.id,
                            adminId: authProvider.user?.id ?? 'usr-admin-001',
                          );
                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('संस्था "${ngo.name}" पडताळणी मंजूर (Approved)! आता ही संस्था ॲपमध्ये लॉगिन करू शकते.'),
                                backgroundColor: AppColors.primaryGreen,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FBButton(
                        label: 'Reject',
                        variant: FBButtonVariant.danger,
                        height: 44,
                        onPressed: () async {
                          final success = await adminProvider.rejectNgo(
                            ngoId: ngo.id,
                            reason: 'Incomplete or unverified 80G/Darpan certificate',
                            adminId: authProvider.user?.id ?? 'usr-admin-001',
                          );
                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('संस्था "${ngo.name}" पडताळणी नाकारली (Rejected).'),
                                backgroundColor: AppColors.errorRed,
                              ),
                            );
                          }
                        },
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

    return RefreshIndicator(
      onRefresh: () => adminProvider.refreshUsers(),
      color: AppColors.primaryGreen,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        itemBuilder: (context, idx) {
          final u = users[idx];
          final avatarImage = AvatarImageHelper.resolve(u.avatarUrl);
          final Color roleBaseColor = switch (u.role) {
            UserRole.donor => AppColors.primaryGreen,
            UserRole.ngo => const Color(0xFF0F4D2E),
            UserRole.volunteer => AppColors.orange,
            UserRole.admin => const Color(0xFF6366F1),
          };

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: u.isSuspended
                    ? AppColors.errorRed.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: u.isSuspended
                        ? AppColors.errorRed.withValues(alpha: 0.15)
                        : roleBaseColor.withValues(alpha: 0.12),
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? (u.fullName.trim().isNotEmpty
                            ? Text(
                                u.fullName.trim().substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: u.isSuspended ? AppColors.errorRed : roleBaseColor,
                                ),
                              )
                            : Icon(
                                switch (u.role) {
                                  UserRole.donor => Icons.soup_kitchen,
                                  UserRole.ngo => Icons.domain,
                                  UserRole.volunteer => Icons.two_wheeler,
                                  UserRole.admin => Icons.admin_panel_settings,
                                },
                                color: u.isSuspended ? AppColors.errorRed : roleBaseColor,
                                size: 24,
                              ))
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                u.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.charcoal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: roleBaseColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                u.role.displayName,
                                style: TextStyle(
                                  color: roleBaseColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (u.isSuspended) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.errorRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'SUSPENDED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 13, color: AppColors.mutedGrey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                u.email,
                                style: const TextStyle(fontSize: 12, color: AppColors.mutedGrey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (u.phone != null && u.phone!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 13, color: AppColors.mutedGrey),
                              const SizedBox(width: 4),
                              Text(
                                u.phone!,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.mutedGrey),
                              ),
                            ],
                          ),
                        ],
                        if (u.isSuspended && u.suspensionReason != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              'कारण: ${u.suspensionReason!}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.errorRed,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!u.isSuspended)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _showSuspendUserDialog(context, u);
                      },
                      child: const Text('Suspend', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600)),
                    )
                  else
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await adminProvider.reactivateUser(
                          userId: u.id,
                          adminId: authProvider.user?.id ?? 'usr-admin-001',
                        );
                      },
                      child: const Text('Reactivate', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
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
                    Expanded(
                      child: Text(
                        'Complaint #${c.id} (${c.category})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          Expanded(
                            child: Text(
                              log.action,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.charcoal),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
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
  final String? trend;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.count,
    this.trend,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedGrey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
