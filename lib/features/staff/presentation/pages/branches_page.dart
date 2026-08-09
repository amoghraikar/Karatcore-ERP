import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../models/rbac_models.dart';
import '../../providers/staff_providers.dart';

class BranchesPage extends ConsumerWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesListProvider);

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
                  Text('Branch Network Management', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Store locations, vault branch administration & staff allocation', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBranchModal(context, ref),
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('Add Branch Location'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          branchesAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Center(child: Text('Error loading branches: $err')),
            data: (branches) {
              return Column(
                children: branches.map((branch) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: KcCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                            child: Icon(Icons.storefront_rounded, color: Theme.of(context).colorScheme.primary, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(branch.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                      child: Text(branch.code, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 11)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(branch.address, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('Manager: ${branch.managerName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 16),
                                    Text('${branch.staffCount} Staff Allocated', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(width: 16),
                                    Text('Established: ${KcFormatters.date(branch.createdAt)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddBranchModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController(text: 'BR-00${DateTime.now().millisecond % 10}');
    final addrCtrl = TextEditingController();
    final mgrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Branch Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Branch Name')),
            const SizedBox(height: 12),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Branch Code')),
            const SizedBox(height: 12),
            TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Full Address')),
            const SizedBox(height: 12),
            TextField(controller: mgrCtrl, decoration: const InputDecoration(labelText: 'Branch Manager Name')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newB = BranchModel(
                id: 'BR-${DateTime.now().millisecondsSinceEpoch % 1000}',
                code: codeCtrl.text,
                name: nameCtrl.text,
                address: addrCtrl.text,
                managerName: mgrCtrl.text,
                staffCount: 1,
                isActive: true,
                createdAt: DateTime.now(),
              );
              await ref.read(staffRepositoryProvider).createBranch(newB);
              ref.invalidate(branchesListProvider);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save Branch'),
          ),
        ],
      ),
    );
  }
}
