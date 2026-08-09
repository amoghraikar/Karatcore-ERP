import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../providers/accounting_providers.dart';

class CashBookPage extends ConsumerWidget {
  const CashBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashAsync = ref.watch(cashBookMovementsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.accounting),
              ),
              const SizedBox(width: 8),
              Text('Cash Book — Vault Cash Ledger', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          const KcMetricCard(
            title: 'Vault Cash Balance',
            value: '₹8,50,000',
            trend: 'Physical Cash Balance Available',
            icon: Icons.payments_rounded,
          ),
          const SizedBox(height: 24),

          Text('Cash Transactions Log', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          cashAsync.when(
            loading: () => const KcSkeletonLoader(height: 300),
            error: (err, st) => Text('Error: $err'),
            data: (txs) {
              if (txs.isEmpty) {
                return const KcEmptyState(
                  title: 'No Cash Movements',
                  subtitle: 'No cash vault deposits or withdrawals logged.',
                );
              }

              return KcCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
                  itemBuilder: (context, index) {
                    final t = txs[index];
                    final isCashIn = t.debitAccountId == 'ACC-101';

                    return ListTile(
                      onTap: () => context.go('/accounting/transactions/${t.id}'),
                      leading: Icon(isCashIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isCashIn ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                      title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Ref: ${t.reference} • ${KcFormatters.dateTime(t.date)}'),
                      trailing: Text(
                        '${isCashIn ? "Cash In +" : "Cash Out -"}${KcFormatters.inr(t.amount)}',
                        style: TextStyle(fontWeight: FontWeight.w800, color: isCashIn ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
