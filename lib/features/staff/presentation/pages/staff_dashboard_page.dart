import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/kc_avatar.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/inputs/kc_search_field.dart';
import '../../models/rbac_models.dart';
import '../../providers/staff_providers.dart';

class StaffDashboardPage extends ConsumerStatefulWidget {
  const StaffDashboardPage({super.key});

  @override
  ConsumerState<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends ConsumerState<StaffDashboardPage> {
  String _searchQuery = '';
  String _selectedRole = 'ALL';
  String _selectedDepartment = 'ALL';
  String _selectedBranch = 'ALL';
  String _selectedStatus = 'ALL';

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListProvider);
    final currentStaff = ref.watch(currentStaffUserProvider);
    final authService = ref.watch(authorizationServiceProvider);
    final canManageStaff = authService.hasPermission(user: currentStaff, permission: AppPermission.createStaff);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Staff Directory & Access Management', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Employee records, role-based security access, branch assignments & activity tracking', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
              if (canManageStaff)
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.staffCreate),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Staff Member'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Staff KPI Dashboard Cards
          staffAsync.when(
            loading: () => const KcSkeletonLoader(height: 120),
            error: (e, s) => const SizedBox.shrink(),
            data: (staffList) {
              final totalCount = staffList.length;
              final activeCount = staffList.where((s) => s.status == StaffStatus.active).length;
              final inactiveCount = staffList.where((s) => s.status == StaffStatus.inactive).length;
              final invitedCount = staffList.where((s) => s.status == StaffStatus.invited).length;
              final managerCount = staffList.where((s) => s.roleCode == 'MANAGER' || s.roleCode == 'ADMIN' || s.roleCode == 'OWNER').length;

              return LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth > 900 ? (constraints.maxWidth - 56) / 5 : (constraints.maxWidth - 14) / 2,
                        child: KcMetricCard(title: 'Total Staff', value: '$totalCount Users', trend: 'Active Directory', icon: Icons.badge_rounded),
                      ),
                      SizedBox(
                        width: constraints.maxWidth > 900 ? (constraints.maxWidth - 56) / 5 : (constraints.maxWidth - 14) / 2,
                        child: KcMetricCard(title: 'Active Staff', value: '$activeCount Staff', trend: 'Operational', icon: Icons.check_circle_rounded),
                      ),
                      SizedBox(
                        width: constraints.maxWidth > 900 ? (constraints.maxWidth - 56) / 5 : (constraints.maxWidth - 14) / 2,
                        child: KcMetricCard(title: 'Inactive / Suspended', value: '$inactiveCount Users', trend: 'Access Off', icon: Icons.block_rounded),
                      ),
                      SizedBox(
                        width: constraints.maxWidth > 900 ? (constraints.maxWidth - 56) / 5 : (constraints.maxWidth - 14) / 2,
                        child: KcMetricCard(title: 'Pending Invitations', value: '$invitedCount Invited', trend: 'Activation Due', icon: Icons.mark_email_unread_rounded),
                      ),
                      SizedBox(
                        width: constraints.maxWidth > 900 ? (constraints.maxWidth - 56) / 5 : constraints.maxWidth,
                        child: KcMetricCard(title: 'Managers & Leads', value: '$managerCount Leads', trend: 'Supervisory', icon: Icons.supervisor_account_rounded),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // Search & Filter Toolbar
          KcCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: KcSearchField(
                        hint: 'Search by Name, Employee ID, Email, Phone, Role, Branch...',
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showFilterBottomSheet(context),
                      icon: const Icon(Icons.filter_list_rounded, size: 18),
                      label: const Text('Filters'),
                    ),
                    if (_selectedRole != 'ALL' || _selectedDepartment != 'ALL' || _selectedBranch != 'ALL' || _selectedStatus != 'ALL' || _searchQuery.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedRole = 'ALL';
                            _selectedDepartment = 'ALL';
                            _selectedBranch = 'ALL';
                            _selectedStatus = 'ALL';
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Staff List Table / Cards
          staffAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Center(child: Text('Error loading staff directory: $err')),
            data: (staffList) {
              final filteredList = staffList.where((s) {
                final matchesSearch = _searchQuery.isEmpty ||
                    s.fullName.toLowerCase().contains(_searchQuery) ||
                    s.employeeId.toLowerCase().contains(_searchQuery) ||
                    s.email.toLowerCase().contains(_searchQuery) ||
                    s.mobile.contains(_searchQuery) ||
                    s.roleCode.toLowerCase().contains(_searchQuery) ||
                    s.department.toLowerCase().contains(_searchQuery) ||
                    s.branchName.toLowerCase().contains(_searchQuery);

                final matchesRole = _selectedRole == 'ALL' || s.roleCode.toUpperCase() == _selectedRole;
                final matchesDept = _selectedDepartment == 'ALL' || s.department == _selectedDepartment;
                final matchesBranch = _selectedBranch == 'ALL' || s.branchId == _selectedBranch;
                final matchesStatus = _selectedStatus == 'ALL' || s.status.name.toUpperCase() == _selectedStatus;

                return matchesSearch && matchesRole && matchesDept && matchesBranch && matchesStatus;
              }).toList();

              if (filteredList.isEmpty) {
                return KcCard(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('No staff members matched your query', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Try adjusting filters or search term.', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                );
              }

              return KcCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Staff Directory (${filteredList.length} Accounts)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowHeight: 44,
                        columns: const [
                          DataColumn(label: Text('Employee', style: TextStyle(fontWeight: FontWeight.w700))),
                          DataColumn(label: Text('Employee ID', style: TextStyle(fontWeight: FontWeight.w700))),
                          DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.w700))),
                          DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.w700))),
                          DataColumn(label: Text('Branch', style: TextStyle(fontWeight: FontWeight.w700))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
                          DataColumn(label: Text('Last Active', style: TextStyle(fontWeight: FontWeight.w700))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
                        ],
                        rows: filteredList.map((staff) {
                          final initials = staff.fullName.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    KcAvatar(initials: initials, size: 34),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(staff.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                        Text(staff.email, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(staff.employeeId, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(staff.roleCode, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 11)),
                                ),
                              ),
                              DataCell(Text(staff.department)),
                              DataCell(Text(staff.branchName)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: staff.status.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(staff.status.label, style: TextStyle(color: staff.status.color, fontWeight: FontWeight.w700, fontSize: 11)),
                                ),
                              ),
                              DataCell(Text(KcFormatters.relativeTime(staff.lastActive))),
                              DataCell(
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                                  onSelected: (action) => _handleRowAction(context, ref, action, staff),
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility_rounded, size: 16), SizedBox(width: 8), Text('View Profile')])),
                                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 16), SizedBox(width: 8), Text('Edit Information')])),
                                    const PopupMenuItem(value: 'permissions', child: Row(children: [Icon(Icons.admin_panel_settings_rounded, size: 16), SizedBox(width: 8), Text('Manage Role & Perms')])),
                                    const PopupMenuItem(value: 'activity', child: Row(children: [Icon(Icons.history_rounded, size: 16), SizedBox(width: 8), Text('View Activity & Audit')])),
                                    if (staff.status == StaffStatus.active)
                                      const PopupMenuItem(value: 'deactivate', child: Row(children: [Icon(Icons.block_rounded, size: 16, color: Color(0xFFDC2626)), SizedBox(width: 8), Text('Deactivate Staff', style: TextStyle(color: Color(0xFFDC2626)))])),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleRowAction(BuildContext context, WidgetRef ref, String action, StaffModel staff) {
    switch (action) {
      case 'view':
        context.go('/staff/${staff.id}');
        break;
      case 'edit':
        context.go('/staff/${staff.id}/edit');
        break;
      case 'permissions':
        context.go('/staff/${staff.id}/permissions');
        break;
      case 'activity':
        context.go('/staff/${staff.id}');
        break;
      case 'deactivate':
        if (staff.isOwner) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)), SizedBox(width: 8), Text('Protected Owner Account')]),
              content: const Text('The primary OWNER account is protected from deactivation to ensure organization administration access remains intact.'),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
            ),
          );
        } else {
          _showDeactivateModal(context, ref, staff);
        }
        break;
    }
  }

  void _showDeactivateModal(BuildContext context, WidgetRef ref, StaffModel staff) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Deactivate Staff — ${staff.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deactivating this account will immediately revoke all active sessions and disable access to KaratCore ERP for ${staff.employeeId}.'),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Reason for Deactivation', hintText: 'e.g. Resigned, Role Transfer, Policy Violation'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await ref.read(staffRepositoryProvider).deactivateStaff(staff.id, controller.text);
              ref.invalidate(staffListProvider);
              if (mounted) {
                messenger.showSnackBar(SnackBar(content: Text('Staff member ${staff.fullName} deactivated.')));
              }
            },
            child: const Text('Deactivate Staff'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Staff Directory', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(labelText: 'Filter by Role'),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('All Roles')),
                DropdownMenuItem(value: 'OWNER', child: Text('Owner')),
                DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                DropdownMenuItem(value: 'MANAGER', child: Text('Manager')),
                DropdownMenuItem(value: 'ACCOUNTANT', child: Text('Accountant')),
                DropdownMenuItem(value: 'LOAN_OFFICER', child: Text('Loan Officer')),
                DropdownMenuItem(value: 'KYC_OFFICER', child: Text('KYC Officer')),
                DropdownMenuItem(value: 'VALUATION_OFFICER', child: Text('Valuation Officer')),
                DropdownMenuItem(value: 'INVENTORY_MANAGER', child: Text('Inventory Manager')),
                DropdownMenuItem(value: 'CASHIER', child: Text('Cashier')),
                DropdownMenuItem(value: 'STAFF', child: Text('Staff')),
                DropdownMenuItem(value: 'VIEWER', child: Text('Viewer')),
              ],
              onChanged: (val) => setState(() => _selectedRole = val ?? 'ALL'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedRole = 'ALL';
                      _selectedDepartment = 'ALL';
                      _selectedBranch = 'ALL';
                      _selectedStatus = 'ALL';
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Clear Filters'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
