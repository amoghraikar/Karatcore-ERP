import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';

import '../../providers/accounting_providers.dart';

class ReceivablesPage extends ConsumerWidget {
  const ReceivablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recAsync = ref.watch(receivablesListProvider);
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
              Text('Accounts Receivable — Customer Due Balances', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          recAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (receivables) {
              if (receivables.isEmpty) {
                return const KcEmptyState(
                  title: 'No Receivables Outstanding',
                  subtitle: 'All customer accounts are settled.',
                );
              }

              return KcCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: receivables.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
                  itemBuilder: (context, index) {
                    final r = receivables[index];

                    return ListTile(
                      onTap: () {
                        if (r.relatedLoanId != null) {
                          context.go('/loans/${r.relatedLoanId}');
                        }
                      },
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEFF6FF),
                        child: Icon(Icons.call_made_rounded, color: Color(0xFF2563EB), size: 20),
                      ),
                      title: Text('${r.customerName} (${r.customerId})', style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('Ref: ${r.reference} • Due Date: ${KcFormatters.date(r.dueDate)} (${r.ageDays} days aged)'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(KcFormatters.inr(r.amountDue), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 2),
                          KcStatusBadge(
                            label: r.status,
                            statusColor: r.status == 'Overdue' ? const Color(0xFFDC2626) : const Color(0xFF059669),
                          ),
                        ],
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
