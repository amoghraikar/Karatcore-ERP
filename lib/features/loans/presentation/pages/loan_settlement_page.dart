import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';

import '../../models/loan_model.dart';
import '../../providers/loan_providers.dart';
import '../../widgets/receipt_preview_dialog.dart';

class LoanSettlementPage extends ConsumerStatefulWidget {
  const LoanSettlementPage({super.key, this.id});

  final String? id;

  @override
  ConsumerState<LoanSettlementPage> createState() => _LoanSettlementPageState();
}

class _LoanSettlementPageState extends ConsumerState<LoanSettlementPage> {
  DisbursementMethod _method = DisbursementMethod.bankTransfer;
  bool _isSubmitting = false;

  String _getTargetId() {
    if (widget.id != null && widget.id!.isNotEmpty) return widget.id!;
    final path = GoRouterState.of(context).uri.path;
    final parts = path.split('/');
    if (parts.length > 2 && parts[2].isNotEmpty) {
      return parts[2];
    }
    return 'KC-LN-9481';
  }

  @override
  Widget build(BuildContext context) {
    final loanId = _getTargetId();
    final loanAsync = ref.watch(loanDetailProvider(loanId));
    final calc = ref.watch(loanCalculationServiceProvider);

    return Scaffold(
      body: loanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Text('Error: $err'),
        data: (loan) {
          if (loan == null) return const Text('Loan Not Found');

          final settlementAmt = calc.calculateSettlementAmount(loan);

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go('/loans/${loan.id}'),
                  ),
                  const SizedBox(width: 8),
                  Text('Full Settlement & Closure — ${loan.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),

              KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer: ${loan.customerName} (${loan.customerId})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF10B981))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CALCULATED SETTLEMENT FIGURES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                          const SizedBox(height: 12),
                          _buildRow('Outstanding Principal', KcFormatters.inr(loan.outstandingPrincipal)),
                          _buildRow('Accrued Interest Due', KcFormatters.inr(loan.accruedInterest)),
                          _buildRow('Processing & Closure Fee', KcFormatters.inr(loan.processingFee)),
                          const Divider(height: 20, color: Color(0xFF10B981)),
                          _buildRow('Total Settlement Amount', KcFormatters.inr(settlementAmt), isBold: true, fontSize: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('Settlement Payment Method *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<DisbursementMethod>(
                      initialValue: _method,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      onChanged: (val) => setState(() => _method = val!),
                      items: DisbursementMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        KcOutlinedButton(label: 'Cancel', onPressed: () => context.go('/loans/${loan.id}')),
                        const Spacer(),
                        KcPrimaryButton(
                          label: 'Confirm Settlement & Close Loan',
                          icon: Icons.check_circle_rounded,
                          isLoading: _isSubmitting,
                          onPressed: () async {
                            final currentContext = context;
                            setState(() => _isSubmitting = true);
                            await ref.read(loanListProvider.notifier).settleLoan(
                                  loanId: loan.id,
                                  settlementAmount: settlementAmt,
                                  method: _method,
                                  settledBy: 'Manager',
                                );

                            if (!mounted || !currentContext.mounted) return;
                            setState(() => _isSubmitting = false);
                            showReceiptPreviewDialog(
                              context: currentContext,
                              receiptTitle: 'Settlement Receipt',
                              receiptNumber: 'KC-RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                              loan: loan,
                              customerName: loan.customerName,
                              amount: settlementAmt,
                              paymentMethod: _method.label,
                              date: DateTime.now(),
                              staffName: 'Manager',
                            );
                          },
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
