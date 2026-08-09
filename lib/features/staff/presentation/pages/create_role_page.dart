import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../models/rbac_models.dart';
import '../../providers/staff_providers.dart';

class CreateRolePage extends ConsumerStatefulWidget {
  const CreateRolePage({super.key});

  @override
  ConsumerState<CreateRolePage> createState() => _CreateRolePageState();
}

class _CreateRolePageState extends ConsumerState<CreateRolePage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();

  final Set<String> _selectedPermissions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cloneFrom = GoRouterState.of(context).uri.queryParameters['cloneFrom'];
      if (cloneFrom != null) {
        final authService = ref.read(authorizationServiceProvider);
        final basePerms = authService.getRolePermissions(cloneFrom);
        setState(() {
          _nameController.text = 'Senior $cloneFrom';
          _codeController.text = 'SENIOR_$cloneFrom';
          _descController.text = 'Cloned role based on $cloneFrom with expanded privileges.';
          _selectedPermissions.addAll(basePerms);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allPerms = AppPermission.all;

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
                    Text('Create / Clone Custom Role', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Define new operational role persona, description & explicit permission toggles', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          KcCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Role Definition', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Role Display Name *', hintText: 'e.g. Senior Loan Officer'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(labelText: 'Role System Code *', hintText: 'e.g. SENIOR_LOAN_OFFICER'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Role Description', hintText: 'e.g. Authorized for high-value loan approvals & vault releases'),
                ),
                const SizedBox(height: 24),

                Text('Permission Privileges Toggle Matrix (${_selectedPermissions.length} Selected)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allPerms.map((perm) {
                    final isSelected = _selectedPermissions.contains(perm);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(perm),
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPermissions.add(perm);
                          } else {
                            _selectedPermissions.remove(perm);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => context.go(AppRoutes.roles), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _saveRole,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Save Custom Role'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveRole() async {
    if (_nameController.text.trim().isEmpty || _codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter role display name and system code.')));
      return;
    }

    final newRole = AppRoleModel(
      code: _codeController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      icon: Icons.shield_rounded,
      color: const Color(0xFF7C3AED),
      defaultPermissions: _selectedPermissions.toList(),
      isSystemRole: false,
    );

    await ref.read(staffRepositoryProvider).createRole(newRole);
    ref.invalidate(rolesListProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Custom role ${newRole.name} saved successfully.')));
      context.go(AppRoutes.roles);
    }
  }
}
