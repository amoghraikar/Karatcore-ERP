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

import '../../models/accounting_model.dart';
import '../../providers/accounting_providers.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final _searchController = TextEditingController();
  SourceModule? _selectedModule;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Financial Transactions', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          // Filters Row
          Card(
            elevation: 0,
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search Transactions by ID, Ref, or Description...',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<SourceModule?>(
                    value: _selectedModule,
                    hint: const Text('Source Module'),
                    onChanged: (m) => setState(() => _selectedModule = m),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Modules')),
                      ...SourceModule.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          txsAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (allTxs) {
              var txs = allTxs;
              if (_selectedModule != null) {
                txs = txs.where((t) => t.sourceModule == _selectedModule).toList();
              }
              final query = _searchController.text.toLowerCase();
              if (query.isNotEmpty) {
                txs = txs.where((t) => t.id.toLowerCase().contains(query) || t.reference.toLowerCase().contains(query) || t.description.toLowerCase().contains(query)).toList();
              }

              if (txs.isEmpty) {
                return const KcEmptyState(
                  title: 'No Financial Transactions Found',
                  subtitle: 'No transactions match the selected filter criteria.',
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

                    return ListTile(
                      onTap: () => context.go('/accounting/transactions/${t.id}'),
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(t.sourceModule.icon, size: 18, color: scheme.primary),
                      ),
                      title: Text('${t.id} • ${t.type}', style: TextStyle(fontWeight: FontWeight.w800, color: t.isReversed ? Colors.grey : scheme.onSurface)),
                      subtitle: Text('${t.description}\nDebit: ${t.debitAccountName} | Credit: ${t.creditAccountName}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(KcFormatters.inr(t.amount), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: t.isReversed ? Colors.grey : scheme.onSurface)),
                          const SizedBox(height: 2),
                          KcStatusBadge(
                            label: t.isReversed ? 'Reversed' : t.status,
                            statusColor: t.isReversed ? const Color(0xFFDC2626) : const Color(0xFF059669),
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
