import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../models/rbac_models.dart';
import '../../providers/staff_providers.dart';

class ModifyStaffPermissionsPage extends ConsumerStatefulWidget {
  const ModifyStaffPermissionsPage({super.key, required this.staffId});

  final String staffId;

  @override
  ConsumerState<ModifyStaffPermissionsPage> createState() => _ModifyStaffPermissionsPageState();
}

class _ModifyStaffPermissionsPageState extends ConsumerState<ModifyStaffPermissionsPage> {
  String? _newRole;
  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffDetailProvider(widget.staffId));
    final rolesAsync = ref.watch(rolesListProvider);
    final authService = ref.watch(authorizationServiceProvider);

    return Scaffold(
      body: staffAsync.when(
        loading: () => const KcSkeletonLoader(height: 400),
        error: (e, s) => Center(child: Text('Error loading staff: $e')),
        data: (staff) {
          if (staff == null) return const Center(child: Text('Staff member not found'));
          _newRole ??= staff.roleCode;

          final currentPerms = authService.getRolePermissions(staff.roleCode).toSet();
          final newPerms = authService.getRolePermissions(_newRole!).toSet();

          final addedPerms = newPerms.difference(currentPerms).toList();
          final removedPerms = currentPerms.difference(newPerms).toList();

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go('/staff/${staff.id}'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Role & Permission Change Workflow', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Re-assign operational role, inspect permission diffs, impact summary & log audit trail', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Staff Header
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.badge_rounded, size: 36, color: Color(0xFF2563EB)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(staff.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('${staff.employeeId} • ${staff.department} • Current Role: ${staff.roleCode}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Select New Role
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Target Role', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    rolesAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, s) => Text('Error loading roles: $e'),
                      data: (roles) {
                        return DropdownButtonFormField<String>(
                          initialValue: _newRole,
                          decoration: const InputDecoration(labelText: 'New Assigned Role'),
                          items: roles.map((r) {
                            return DropdownMenuItem(value: r.code, child: Text('${r.name} (${r.code})'));
                          }).toList(),
                          onChanged: (val) => setState(() => _newRole = val),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Permission Difference Impact Summary
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Permission Difference Impact Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    if (addedPerms.isNotEmpty) ...[
                      Text('Added Permissions (+${addedPerms.length}):', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: addedPerms.map((p) => Chip(avatar: const Icon(Icons.add_circle_rounded, size: 14, color: Color(0xFF059669)), label: Text(p, style: const TextStyle(fontSize: 11)))).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (removedPerms.isNotEmpty) ...[
                      Text('Removed Permissions (-${removedPerms.length}):', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: removedPerms.map((p) => Chip(avatar: const Icon(Icons.remove_circle_rounded, size: 14, color: Color(0xFFDC2626)), label: Text(p, style: const TextStyle(fontSize: 11)))).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (addedPerms.isEmpty && removedPerms.isEmpty)
                      const Text('No permission differences detected between selected roles.', style: TextStyle(color: Colors.grey)),
                    if (addedPerms.length > 5) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFF59E0B))),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
                            SizedBox(width: 10),
                            Expanded(child: Text('Warning: This role change grants significant additional access rights across accounting and financial modules.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reason & Action
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _reasonController,
                      decoration: const InputDecoration(labelText: 'Reason for Role Change *', hintText: 'e.g. Promoted to Senior Loan Officer, Department Transfer'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(onPressed: () => context.go('/staff/${staff.id}'), child: const Text('Cancel')),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (_reasonController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a reason for the role change.')));
                              return;
                            }

                            final messenger = ScaffoldMessenger.of(context);
                            final router = GoRouter.of(context);

                            final updated = staff.copyWith(roleCode: _newRole);
                            await ref.read(staffRepositoryProvider).updateStaff(updated);

                            await ref.read(staffRepositoryProvider).logAuditEvent(
                                  StaffAuditModel(
                                    id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
                                    timestamp: DateTime.now(),
                                    actorName: 'Current User',
                                    targetStaffId: staff.id,
                                    action: 'ROLE_CHANGED',
                                    description: 'Changed role from ${staff.roleCode} to $_newRole',
                                    previousState: staff.roleCode,
                                    newState: _newRole!,
                                    reason: _reasonController.text,
                                  ),
                                );

                            ref.invalidate(staffListProvider);
                            ref.invalidate(staffDetailProvider(staff.id));

                            messenger.showSnackBar(SnackBar(content: Text('Role updated to $_newRole for ${staff.fullName}.')));
                            router.go('/staff/${staff.id}');
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Confirm Role Change'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
