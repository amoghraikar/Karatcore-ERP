import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../providers/staff_providers.dart';

class RolesPage extends ConsumerWidget {
  const RolesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesListProvider);
    final staffAsync = ref.watch(staffListProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Role Management', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Configure system access personas, duplicate custom roles & audit granted permission scopes', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.go(AppRoutes.permissions),
                    icon: const Icon(Icons.grid_on_rounded),
                    label: const Text('View Permission Matrix'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.roleCreate),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create / Clone Role'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          rolesAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Center(child: Text('Error loading roles: $err')),
            data: (roles) {
              final staffList = staffAsync.valueOrNull ?? [];

              Widget buildRoleCard(role) {
                final assignedCount = staffList.where((s) => s.roleCode == role.code).length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: KcCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: role.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: Icon(role.icon, color: role.color, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(role.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: role.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                    child: Text(role.code, style: TextStyle(color: role.color, fontWeight: FontWeight.w800, fontSize: 11)),
                                  ),
                                  if (role.isSystemRole) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                      child: const Text('SYSTEM DEFAULT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(role.description, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('$assignedCount Staff Assigned', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 16),
                                  Text('${role.defaultPermissions.length} Active Permissions', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'clone') {
                              context.go('${AppRoutes.roleCreate}?cloneFrom=${role.code}');
                            } else if (action == 'matrix') {
                              context.go(AppRoutes.permissions);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'clone', child: Row(children: [Icon(Icons.copy_rounded, size: 16), SizedBox(width: 8), Text('Duplicate / Clone Role')])),
                            const PopupMenuItem(value: 'matrix', child: Row(children: [Icon(Icons.grid_on_rounded, size: 16), SizedBox(width: 8), Text('View Permission Scope')])),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Color(0xFF7C3AED), size: 20),
                      const SizedBox(width: 8),
                      Text('Configured Application Roles (${roles.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...roles.map(buildRoleCard),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
