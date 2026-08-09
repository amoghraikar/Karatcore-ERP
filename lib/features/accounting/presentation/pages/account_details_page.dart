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

class AccountDetailsPage extends ConsumerWidget {
  const AccountDetailsPage({super.key, this.id});

  final String? id;

  String _getTargetId(BuildContext context) {
    if (id != null && id!.isNotEmpty) return id!;
    final path = GoRouterState.of(context).uri.path;
    final parts = path.split('/');
    if (parts.length > 3 && parts[3].isNotEmpty) {
      return parts[3];
    }
    return 'ACC-101';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetId = _getTargetId(context);
    final accountAsync = ref.watch(accountDetailProvider(targetId));
    final txsAsync = ref.watch(financialTransactionsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: accountAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Text('Error: $err'),
        data: (acc) {
          if (acc == null) {
            return KcEmptyState(
              title: 'Account Not Found',
              subtitle: 'No account record found for ID "$targetId".',
              action: ElevatedButton(
                onPressed: () => context.go(AppRoutes.accountingAccounts),
                child: const Text('Back to Chart of Accounts'),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go(AppRoutes.accountingAccounts),
                  ),
                  const SizedBox(width: 8),
                  Text('Account Ledger — ${acc.name}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),

              // Account Header Summary Card
              KcCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: acc.type.color.withValues(alpha: 0.15),
                      child: Icon(Icons.menu_book_rounded, color: acc.type.color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                          const SizedBox(height: 2),
                          Text('Account ID: ${acc.id} • Type: ${acc.type.label} • Category: ${acc.category.label}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(KcFormatters.inr(acc.currentBalance), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                        const SizedBox(height: 2),
                        Text('Opening Balance: ${KcFormatters.inr(acc.openingBalance)}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Transaction Ledger History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),

              txsAsync.when(
                loading: () => const KcSkeletonLoader(height: 300),
                error: (err, st) => Text('Error: $err'),
                data: (allTxs) {
                  final txs = allTxs.where((t) => t.debitAccountId == acc.id || t.creditAccountId == acc.id).toList();

                  if (txs.isEmpty) {
                    return const KcEmptyState(
                      title: 'No Ledger Entries',
                      subtitle: 'No financial transactions posted for this account.',
                    );
                  }

                  return KcCard(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: txs.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.2)),
                      itemBuilder: (context, index) {
                        final t = txs[index];
                        final isDebit = t.debitAccountId == acc.id;

                        return ListTile(
                          onTap: () => context.go('/accounting/transactions/${t.id}'),
                          leading: Icon(isDebit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isDebit ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                          title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('Ref: ${t.reference} • ${KcFormatters.dateTime(t.date)}'),
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
          );
        },
      ),
    );
  }
}
