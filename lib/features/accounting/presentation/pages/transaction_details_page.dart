import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';

import '../../models/accounting_model.dart';
import '../../providers/accounting_providers.dart';

class TransactionDetailsPage extends ConsumerStatefulWidget {
  const TransactionDetailsPage({super.key, this.id});

  final String? id;

  @override
  ConsumerState<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends ConsumerState<TransactionDetailsPage> {
  bool _isReversing = false;

  String _getTargetId() {
    if (widget.id != null && widget.id!.isNotEmpty) return widget.id!;
    final path = GoRouterState.of(context).uri.path;
    final parts = path.split('/');
    if (parts.length > 3 && parts[3].isNotEmpty) {
      return parts[3];
    }
    return 'KC-TX-10001';
  }

  void _showReversalDialog(FinancialTransactionModel tx) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reverse Accounting Transaction', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Immutable Reversal Rule: Posted accounting entries cannot be deleted. A reversing transaction with swapped Debit and Credit accounts will be created.'),
            const SizedBox(height: 12),
            KcTextField(
              controller: reasonController,
              label: 'Mandatory Reversal Reason *',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: _isReversing
                ? null
                : () async {
                    if (reasonController.text.trim().isEmpty) return;
                    final currentNav = Navigator.of(ctx);

                    setState(() => _isReversing = true);
                    await ref.read(financialTransactionsProvider.notifier).reverseTx(
                          tx.id,
                          reasonController.text.trim(),
                          'Manager',
                        );

                    if (mounted) {
                      setState(() => _isReversing = false);
                      currentNav.pop();
                    }
                  },
            child: _isReversing
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Confirm Reversal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetId = _getTargetId();
    final txAsync = ref.watch(transactionDetailProvider(targetId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Text('Error: $err'),
        data: (tx) {
          if (tx == null) {
            return KcEmptyState(
              title: 'Transaction Not Found',
              subtitle: 'No financial transaction found for ID "$targetId".',
              action: ElevatedButton(
                onPressed: () => context.go(AppRoutes.accountingTransactions),
                child: const Text('Back to Transactions'),
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
                    onPressed: () => context.go(AppRoutes.accountingTransactions),
                  ),
                  const SizedBox(width: 8),
                  Text('Transaction Details — ${tx.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),

              KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.type, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                            const SizedBox(height: 2),
                            Text('Reference: ${tx.reference} • Source: ${tx.sourceModule.label}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                        KcStatusBadge(
                          label: tx.isReversed ? 'Reversed' : tx.status,
                          statusColor: tx.isReversed ? const Color(0xFFDC2626) : const Color(0xFF059669),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    _buildRow('Transaction Amount', KcFormatters.inr(tx.amount), isBold: true, fontSize: 18),
                    _buildRow('Debit Account (+ Assets / Expenses)', '${tx.debitAccountId} — ${tx.debitAccountName}'),
                    _buildRow('Credit Account (- Assets / + Revenue)', '${tx.creditAccountId} — ${tx.creditAccountName}'),
                    _buildRow('Description', tx.description),
                    _buildRow('Date Recorded', KcFormatters.dateTime(tx.date)),
                    _buildRow('Created By', tx.createdBy),

                    if (tx.isReversed) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFEF4444))),
                        child: Text('This transaction was REVERSED. Reversal Entry: ${tx.reversalTransactionId ?? "REV-TX"}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF991B1B))),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action buttons & Source linking
                    Row(
                      children: [
                        if (tx.sourceModule == SourceModule.loan && tx.sourceId.startsWith('KC-LN'))
                          KcPrimaryButton(
                            label: 'Open Source Loan (${tx.sourceId})',
                            icon: Icons.launch_rounded,
                            onPressed: () => context.go('/loans/${tx.sourceId}'),
                          ),
                        const Spacer(),
                        if (!tx.isReversed)
                          KcOutlinedButton(
                            label: 'Reverse Transaction',
                            icon: Icons.undo_rounded,
                            onPressed: () => _showReversalDialog(tx),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(String title, String val, {bool isBold = false, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
          Text(val, style: TextStyle(fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, fontSize: fontSize)),
        ],
      ),
    );
  }
}
