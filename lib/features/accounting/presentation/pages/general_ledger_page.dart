import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../providers/accounting_providers.dart';

class GeneralLedgerPage extends ConsumerStatefulWidget {
  const GeneralLedgerPage({super.key});

  @override
  ConsumerState<GeneralLedgerPage> createState() => _GeneralLedgerPageState();
}

class _GeneralLedgerPageState extends ConsumerState<GeneralLedgerPage> {
  String? _selectedAccountId = 'ACC-101'; // Cash in Vault

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(chartOfAccountsProvider(null));
    final txsAsync = ref.watch(financialTransactionsProvider);
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
              Text('General Ledger Explorer', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          // Account Selector Header
          accountsAsync.when(
            loading: () => const KcSkeletonLoader(height: 80),
            error: (err, st) => Text('Error: $err'),
            data: (accounts) {
              return Card(
                elevation: 0,
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded),
                      const SizedBox(width: 12),
                      const Text('Select Account for Ledger View:', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedAccountId,
                          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          onChanged: (val) => setState(() => _selectedAccountId = val),
                          items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.id} — ${a.name} (${a.type.label})'))).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          txsAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (allTxs) {
              final txs = allTxs.where((t) => t.debitAccountId == _selectedAccountId || t.creditAccountId == _selectedAccountId).toList();

              if (txs.isEmpty) {
                return const KcEmptyState(
                  title: 'No Ledger Transactions',
                  subtitle: 'No financial entries posted for the selected account.',
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
                    final isDebit = t.debitAccountId == _selectedAccountId;

                    return ListTile(
                      onTap: () => context.go('/accounting/transactions/${t.id}'),
                      leading: Icon(isDebit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isDebit ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                      title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Ref: ${t.reference} • Source: ${t.sourceModule.label} • ${KcFormatters.dateTime(t.date)}'),
                      trailing: Text(
                        '${isDebit ? "+" : "-"}${KcFormatters.inr(t.amount)}',
                        style: TextStyle(fontWeight: FontWeight.w800, color: isDebit ? const Color(0xFF059669) : const Color(0xFFDC2626)),
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
