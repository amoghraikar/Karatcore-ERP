import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/inputs/kc_search_field.dart';
import '../../models/rbac_models.dart';
import '../../providers/staff_providers.dart';

class PermissionMatrixPage extends ConsumerStatefulWidget {
  const PermissionMatrixPage({super.key});

  @override
  ConsumerState<PermissionMatrixPage> createState() => _PermissionMatrixPageState();
}

class _PermissionMatrixPageState extends ConsumerState<PermissionMatrixPage> {
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesListProvider);
    final authService = ref.watch(authorizationServiceProvider);
    final allPerms = AppPermission.all;

    final filteredPerms = allPerms.where((p) {
      final matchesSearch = _searchQuery.isEmpty || p.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'ALL' || p.startsWith(_selectedCategory);
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.roles),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Global RBAC Permission Matrix', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Permissions × Roles cross-functional access control matrix', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters
          KcCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: KcSearchField(
                    hint: 'Search permission code...',
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Modules')),
                    DropdownMenuItem(value: 'VIEW_', child: Text('View Scope')),
                    DropdownMenuItem(value: 'CREATE_', child: Text('Create Scope')),
                    DropdownMenuItem(value: 'EDIT_', child: Text('Edit Scope')),
                    DropdownMenuItem(value: 'MANAGE_', child: Text('Management Scope')),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val ?? 'ALL'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Matrix View
          rolesAsync.when(
            loading: () => const KcSkeletonLoader(height: 500),
            error: (err, st) => Center(child: Text('Error loading roles: $err')),
            data: (roles) {
              if (context.isMobile) {
                // Mobile Role-first view
                return Column(
                  children: roles.map((role) {
                    final rolePerms = authService.getRolePermissions(role.code);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: KcCard(
                        padding: const EdgeInsets.all(16),
                        child: ExpansionTile(
                          title: Text(role.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text('${rolePerms.length} Permissions Allowed'),
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: rolePerms.map((p) => Chip(label: Text(p, style: const TextStyle(fontSize: 10)))).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }

              // Desktop Table Grid View
              return KcCard(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 14,
                    headingRowHeight: 48,
                    columns: [
                      const DataColumn(label: Text('Permission Privilege', style: TextStyle(fontWeight: FontWeight.w800))),
                      ...roles.map((r) {
                        return DataColumn(
                          label: RotatedBox(
                            quarterTurns: 0,
                            child: Text(r.name, style: TextStyle(fontWeight: FontWeight.w800, color: r.color, fontSize: 12)),
                          ),
                        );
                      }),
                    ],
                    rows: filteredPerms.map((perm) {
                      return DataRow(
                        cells: [
                          DataCell(Text(perm, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 12))),
                          ...roles.map((r) {
                            final perms = authService.getRolePermissions(r.code);
                            final isAllowed = r.code == 'OWNER' || perms.contains(perm);
                            return DataCell(
                              Icon(
                                isAllowed ? Icons.check_circle_rounded : Icons.cancel_outlined,
                                color: isAllowed ? const Color(0xFF059669) : Colors.grey.withValues(alpha: 0.3),
                                size: 18,
                              ),
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
