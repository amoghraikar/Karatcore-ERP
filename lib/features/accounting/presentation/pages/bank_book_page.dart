import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';

import '../../providers/accounting_providers.dart';

class BankBookPage extends ConsumerStatefulWidget {
  const BankBookPage({super.key});

  @override
  ConsumerState<BankBookPage> createState() => _BankBookPageState();
}

class _BankBookPageState extends ConsumerState<BankBookPage> {
  void _showTransferDialog() {
    final amountController = TextEditingController(text: '100000');
    final refController = TextEditingController(text: 'TRF-BANK-001');
    final descController = TextEditingController(text: 'Vault Cash deposit into HDFC Main Operating Account');
    String fromAccId = 'ACC-101'; // Cash in Vault
    String toAccId = 'ACC-102'; // HDFC Bank

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cash / Bank Transfer Workflow', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: fromAccId,
              decoration: const InputDecoration(labelText: 'From Account (Source) *', border: OutlineInputBorder()),
              onChanged: (val) => fromAccId = val!,
              items: const [
                DropdownMenuItem(value: 'ACC-101', child: Text('ACC-101 — Cash in Vault')),
                DropdownMenuItem(value: 'ACC-102', child: Text('ACC-102 — HDFC Bank Main Operating Account')),
                DropdownMenuItem(value: 'ACC-103', child: Text('ACC-103 — SBI Jeweller Business Account')),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: toAccId,
              decoration: const InputDecoration(labelText: 'To Account (Destination) *', border: OutlineInputBorder()),
              onChanged: (val) => toAccId = val!,
              items: const [
                DropdownMenuItem(value: 'ACC-102', child: Text('ACC-102 — HDFC Bank Main Operating Account')),
                DropdownMenuItem(value: 'ACC-103', child: Text('ACC-103 — SBI Jeweller Business Account')),
                DropdownMenuItem(value: 'ACC-101', child: Text('ACC-101 — Cash in Vault')),
              ],
            ),
            const SizedBox(height: 12),
            KcTextField(controller: amountController, label: 'Transfer Amount (₹) *', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            KcTextField(controller: refController, label: 'Bank Ref / UTR Number *'),
            const SizedBox(height: 12),
            KcTextField(controller: descController, label: 'Transfer Description'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(amountController.text) ?? 0.0;
              if (amt <= 0) return;

              final currentNav = Navigator.of(ctx);
              await ref.read(accountingRepositoryProvider).transferCashBank(
                    fromAccountId: fromAccId,
                    toAccountId: toAccId,
                    amount: amt,
                    reference: refController.text.trim(),
                    description: descController.text.trim(),
                    createdBy: 'Accountant',
                  );

              ref.invalidate(financialTransactionsProvider);
              ref.invalidate(bankBookMovementsProvider);
              ref.invalidate(cashBookMovementsProvider);
              ref.invalidate(accountingDashboardMetricsProvider);

              if (mounted) currentNav.pop();
            },
            child: const Text('Post Transfer Entry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bankAsync = ref.watch(bankBookMovementsProvider);
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
              Text('Bank Book — Business Bank Accounts', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              KcPrimaryButton(label: 'Transfer Cash / Bank', icon: Icons.sync_alt_rounded, onPressed: _showTransferDialog),
            ],
          ),
          const SizedBox(height: 20),

          const Row(
            children: [
              Expanded(
                child: KcMetricCard(
                  title: 'HDFC Bank Operating Account',
                  value: '₹42,00,000',
                  trend: 'ACC-102 • Active Balance',
                  icon: Icons.account_balance_rounded,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KcMetricCard(
                  title: 'SBI Jeweller Business Account',
                  value: '₹18,50,000',
                  trend: 'ACC-103 • Active Balance',
                  icon: Icons.account_balance_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Bank Transactions Log', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          bankAsync.when(
            loading: () => const KcSkeletonLoader(height: 300),
            error: (err, st) => Text('Error: $err'),
            data: (txs) {
              if (txs.isEmpty) {
                return const KcEmptyState(
                  title: 'No Bank Movements',
                  subtitle: 'No bank deposits or withdrawals logged.',
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
                    final isDeposit = t.debitAccountId == 'ACC-102' || t.debitAccountId == 'ACC-103';

                    return ListTile(
                      onTap: () => context.go('/accounting/transactions/${t.id}'),
                      leading: Icon(isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isDeposit ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                      title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Ref: ${t.reference} • ${KcFormatters.dateTime(t.date)}'),
                      trailing: Text(
                        '${isDeposit ? "Deposit +" : "Withdrawal -"}${KcFormatters.inr(t.amount)}',
                        style: TextStyle(fontWeight: FontWeight.w800, color: isDeposit ? const Color(0xFF059669) : const Color(0xFFDC2626)),
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
