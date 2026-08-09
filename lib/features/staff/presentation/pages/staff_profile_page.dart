import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/kc_avatar.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../models/rbac_models.dart';
import '../../providers/staff_providers.dart';

class StaffProfilePage extends ConsumerStatefulWidget {
  const StaffProfilePage({super.key, required this.staffId});

  final String staffId;

  @override
  ConsumerState<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends ConsumerState<StaffProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffDetailProvider(widget.staffId));
    final authService = ref.watch(authorizationServiceProvider);

    return Scaffold(
      body: staffAsync.when(
        loading: () => const KcSkeletonLoader(height: 500),
        error: (err, st) => Center(child: Text('Error loading staff details: $err')),
        data: (staff) {
          if (staff == null) {
            return const Center(child: Text('Staff member not found'));
          }

          final initials = staff.fullName.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
          final userPerms = authService.getUserPermissions(staff);

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go(AppRoutes.staff),
                  ),
                  const SizedBox(width: 8),
                  Text('Staff Profile & Security Dossier', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),

              // Profile Header Card
              KcCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    KcAvatar(initials: initials, size: 64),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(staff.fullName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                child: Text(staff.roleCode, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: staff.status.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                child: Text(staff.status.label, style: TextStyle(color: staff.status.color, fontWeight: FontWeight.w700, fontSize: 11)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${staff.employeeId} • ${staff.department} • ${staff.branchName}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text('Last active: ${KcFormatters.dateTime(staff.lastActive)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/staff/${staff.id}/permissions'),
                      icon: const Icon(Icons.admin_panel_settings_rounded),
                      label: const Text('Manage Role & Perms'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab Bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Permissions'),
                  Tab(text: 'Roles'),
                  Tab(text: 'Activity'),
                  Tab(text: 'Audit Trail'),
                  Tab(text: 'Sessions'),
                ],
              ),
              const SizedBox(height: 20),

              // Tab Views
              SizedBox(
                height: 420,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(staff),
                    _buildPermissionsTab(userPerms),
                    _buildRolesTab(staff),
                    _buildActivityTab(staff.id),
                    _buildAuditTab(staff.id),
                    _buildSessionsTab(staff.id),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(StaffModel staff) {
    return KcCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account & Employment Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _detailRow('Full Name', staff.fullName),
          _detailRow('Employee ID', staff.employeeId),
          _detailRow('Work Email', staff.email),
          _detailRow('Mobile Phone', staff.mobile),
          _detailRow('Primary Role', staff.roleCode),
          _detailRow('Department', staff.department),
          _detailRow('Branch Location', staff.branchName),
          _detailRow('Joining Date', KcFormatters.date(staff.joiningDate)),
          _detailRow('Account Status', staff.status.label),
          _detailRow('Created At', KcFormatters.dateTime(staff.createdAt)),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab(List<String> userPerms) {
    return KcCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Permission Privileges (${userPerms.length} Total)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: userPerms.map((p) {
                  return Chip(
                    avatar: const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF059669)),
                    label: Text(p, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesTab(StaffModel staff) {
    return KcCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assigned Operational Role', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ListTile(
            leading: const Icon(Icons.verified_user_rounded, color: Color(0xFF7C3AED), size: 36),
            title: Text(staff.roleCode, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            subtitle: const Text('Primary system role providing default functional scope across KaratCore modules.'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab(String staffId) {
    return KcCard(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text('Operational Activity Log', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const ListTile(leading: Icon(Icons.monetization_on_rounded, color: Colors.blue), title: Text('Disbursed Gold Loan #KC-LN-00123'), subtitle: Text('Amount: ₹1,85,000 • 2 hours ago')),
          const ListTile(leading: Icon(Icons.verified_user_rounded, color: Colors.green), title: Text('Verified Customer KYC #KC-KYC-0041'), subtitle: Text('Pan & Aadhaar validated • 5 hours ago')),
          const ListTile(leading: Icon(Icons.receipt_long_rounded, color: Colors.amber), title: Text('Recorded Interest Repayment #KC-RCP-0092'), subtitle: Text('Amount: ₹12,500 • 1 day ago')),
        ],
      ),
    );
  }

  Widget _buildAuditTab(String staffId) {
    final auditAsync = ref.watch(staffAuditTrailProvider(staffId));
    return KcCard(
      padding: const EdgeInsets.all(20),
      child: auditAsync.when(
        loading: () => const KcSkeletonLoader(height: 200),
        error: (e, s) => Text('Error loading audit: $e'),
        data: (auditList) {
          return ListView.builder(
            itemCount: auditList.length,
            itemBuilder: (ctx, i) {
              final a = auditList[i];
              return ListTile(
                leading: const Icon(Icons.history_toggle_off_rounded, color: Color(0xFF2563EB)),
                title: Text('${a.action} — ${a.description}', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Actor: ${a.actorName} • ${KcFormatters.dateTime(a.timestamp)}'),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSessionsTab(String staffId) {
    final sessionsAsync = ref.watch(staffSessionsProvider(staffId));
    return KcCard(
      padding: const EdgeInsets.all(20),
      child: sessionsAsync.when(
        loading: () => const KcSkeletonLoader(height: 200),
        error: (e, s) => Text('Error loading sessions: $e'),
        data: (sessions) {
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (ctx, i) {
              final s = sessions[i];
              return ListTile(
                leading: Icon(s.isCurrentSession ? Icons.laptop_mac_rounded : Icons.devices_other_rounded, color: s.isCurrentSession ? Colors.green : Colors.grey),
                title: Text('${s.deviceName} (${s.platform}) ${s.isCurrentSession ? '[Current Session]' : ''}', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('IP: ${s.ipAddress} • Login: ${KcFormatters.dateTime(s.loginTime)}'),
                trailing: TextButton(
                  onPressed: () async {
                    await ref.read(staffRepositoryProvider).revokeSession(s.id);
                    ref.invalidate(staffSessionsProvider(staffId));
                  },
                  child: const Text('Revoke Session', style: TextStyle(color: Colors.red)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
