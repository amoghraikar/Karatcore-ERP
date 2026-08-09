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

class PayablesPage extends ConsumerWidget {
  const PayablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payAsync = ref.watch(payablesListProvider);
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
              Text('Accounts Payable — Vendor & Bullion Supplier Dues', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          payAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (payables) {
              if (payables.isEmpty) {
                return const KcEmptyState(
                  title: 'No Payables Due',
                  subtitle: 'All vendor invoices and trade accounts are clear.',
                );
              }

              return KcCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: payables.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
                  itemBuilder: (context, index) {
                    final p = payables[index];

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFEF3C7),
                        child: Icon(Icons.call_received_rounded, color: Color(0xFFD97706), size: 20),
                      ),
                      title: Text(p.vendorName, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('Ref: ${p.reference} • Category: ${p.category.label} • Due Date: ${KcFormatters.date(p.dueDate)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(KcFormatters.inr(p.amountDue), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 2),
                          KcStatusBadge(
                            label: p.status,
                            statusColor: p.status == 'Overdue' ? const Color(0xFFDC2626) : const Color(0xFFD97706),
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
