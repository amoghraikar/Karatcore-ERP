import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../providers/inventory_providers.dart';

class InventoryMovementsPage extends ConsumerWidget {
  const InventoryMovementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsync = ref.watch(inventoryMovementsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.ornaments),
              ),
              const SizedBox(width: 8),
              Text('Stock Movements Audit Log', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          movementsAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => KcErrorState(
              message: 'Unable to load stock movements: ${err.toString()}',
              onRetry: () => ref.invalidate(inventoryMovementsProvider),
            ),
            data: (movements) {
              if (movements.isEmpty) {
                return const KcEmptyState(title: 'No Movements Recorded', subtitle: 'No inventory movements logged yet.');
              }

              return KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All Vault Movements (${movements.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: movements.length,
                      separatorBuilder: (context, index) => const Divider(height: 20),
                      itemBuilder: (context, index) {
                        final m = movements[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            child: Icon(m.type.icon, size: 18, color: scheme.primary),
                          ),
                          title: Text(m.type.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('From: ${m.fromLocation}\nTo: ${m.toLocation}\nReason: ${m.reason} • Actor: ${m.actorName}'),
                          trailing: Text(KcFormatters.dateTime(m.date), style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                        );
                      },
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
}
